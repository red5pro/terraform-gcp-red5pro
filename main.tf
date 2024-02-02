locals {
  single                               = var.type == "single" ? true : false
  cluster                              = var.type == "cluster" ? true : false
  autoscaling                          = var.type == "autoscaling" ? true : false
  google_cloud_project                 = var.create_new_google_project ? google_project.new_google_project[0].project_id : data.google_project.existing_gcp_project[0].project_id
  ssh_private_key_path                 = var.create_new_ssh_keys ? local_file.red5pro_ssh_key_pem[0].filename : var.existing_private_ssh_key_path
  public_ssh_key                       = var.create_new_ssh_keys ? tls_private_key.red5pro_ssh_key[0].public_key_openssh : file(var.existing_public_ssh_key_path)
  private_ssh_key                      = var.create_new_ssh_keys ? tls_private_key.red5pro_ssh_key[0].private_key_pem : file(var.existing_private_ssh_key_path)
  vpc_network_name                     = var.vpc_create ? google_compute_network.vpc_red5_network[0].name : data.google_compute_network.existing_vpc_network[0].name
  single_server_ip                     = local.single ? google_compute_instance.red5_single_server[0].network_interface.0.access_config.0.nat_ip : null
  cluster_or_autoscaling               = local.cluster || local.autoscaling ? true : false
  mysql_local_enable                   = local.autoscaling ? false : local.cluster && var.mysql_database_create ? false : true
  mysql_db_system_create               = local.autoscaling ? true : local.cluster && var.mysql_database_create ? true : false
  mysql_host                           = local.autoscaling ? google_sql_database_instance.mysql_database[0].ip_address.0.ip_address : local.cluster && var.mysql_database_create ? google_sql_database_instance.mysql_database[0].ip_address.0.ip_address : "localhost"
  stream_manager_ip                    = local.autoscaling ? google_compute_instance.red5_stream_manager_server[0].network_interface.0.access_config.0.nat_ip : local.cluster ? google_compute_instance.red5_stream_manager_server[0].network_interface.0.access_config.0.nat_ip : null
}

################################################################################
# Google Cloud Project
################################################################################
# Create a new project in google cloud account
resource "google_project" "new_google_project" {
  count      = var.create_new_google_project ? 1 : 0
  name       = "${var.new_google_project_name}"
  project_id = "${var.name}-${var.new_google_project_name}"
  org_id     = var.google_cloud_organization_id
}

# Use existing project of google cloud account
data "google_project" "existing_gcp_project" {
  count      = var.create_new_google_project ? 0 : 1
  project_id = var.existing_google_project_id
}

resource "google_project_service" "google_api_enable" {
  count                      = var.create_new_google_project ? 1 : 0
  project                    = google_project.new_google_project[0].project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

################################################################################
# SSH_KEY
################################################################################
# SSH key pair generation
resource "tls_private_key" "red5pro_ssh_key" {
  count               = var.create_new_ssh_keys ? 1 : 0
  algorithm           = "RSA"
  rsa_bits            = 4096
}
# Save SSH key pair files to local folder
resource "local_file" "red5pro_ssh_key_pem" {
  count               = var.create_new_ssh_keys ? 1 : 0
  filename            = "./${var.new_ssh_key_name}.pem"
  content             = tls_private_key.red5pro_ssh_key[0].private_key_pem
  file_permission     = "0400"
}

resource "local_file" "red5pro_ssh_key_pub" {
  count               = var.create_new_ssh_keys ? 1 : 0
  filename            = "./${var.new_ssh_key_name}.pub"
  content             = tls_private_key.red5pro_ssh_key[0].public_key_openssh
}

################################################################################
# VPC and Network Configuration
################################################################################
# Create VPC
resource "google_compute_network" "vpc_red5_network" {
  count                   = var.vpc_create ? 1 : 0
  name                    = "${var.name}-red5-vpc"
  project                 = local.google_cloud_project
  auto_create_subnetworks = true
  delete_default_routes_on_create = false
}

data "google_compute_network" "existing_vpc_network" {
  count                   = var.vpc_create ? 0 : 1
  name                    = var.existing_vpc_network_name
  project                 = local.google_cloud_project
}

data "google_compute_zones" "available_zone" {
  region                  = var.google_region
  project                 = local.google_cloud_project
  status                  = "UP"
}

################################################################################
# Red5 Single Server Configuration
################################################################################
# Create security group
resource "google_compute_firewall" "red5_single_firewall" {
  count         = local.single ? 1 : 0
  name          = "${var.name}-red5-single-firewall"
  network       = local.vpc_network_name
  priority      = 1000
  allow {
    protocol    = "icmp"
  }

  allow {
    protocol    = "tcp"
    ports       = var.red5_single_firewall_ports
  }

  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
}

# Red5 Pro single server instance
resource "google_compute_instance" "red5_single_server" {
  count        = local.single ? 1 : 0
  name         = "${var.name}-red5-single-server"
  machine_type = var.single_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type  = var.single_server_boot_disk_type
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.red5pro_round_trip_auth_endpoint_invalidate}'",
      "export NODE_CLOUDSTORAGE_ENABLE='${var.red5pro_cloudstorage_enable}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_ACCESS_KEY='${var.red5pro_google_storage_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_SECRET_ACCESS_KEY='${var.red5pro_google_storage_secret_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_BUCKET_NAME='${var.red5pro_google_storage_bucket_name}'",
      "export NODE_CLOUDSTORAGE_POSTPROCESSOR_ENABLE='${var.red5pro_cloudstorage_postprocessor_enable}'",
      "export SSL_ENABLE='${var.https_letsencrypt_enable}'",
      "export SSL_DOMAIN='${var.https_letsencrypt_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_letsencrypt_certificate_email}'",
      "export SSL_PASSWORD='${var.https_letsencrypt_certificate_password}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

################################################################################
# Red5 Stream Manager Server Configuration
################################################################################
# Create security group for stream manager
resource "google_compute_firewall" "red5_stream_manager_firewall" {
  count         = local.cluster_or_autoscaling ? 1 : 0
  name          = "${var.name}-red5-stream-manager-firewall"
  network       = local.vpc_network_name
  allow {
    protocol    = "icmp"
  }
  allow {
    protocol    = "tcp"
    ports       = var.red5_stream_manager_firewall_tcp_ports
  }
  allow {
    protocol    = "udp"
    ports       = var.red5_stream_manager_firewall_udp_ports
  }
  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
}

# Red5 Pro Stream Manager Instance
resource "google_compute_instance" "red5_stream_manager_server" {
  count        = local.cluster_or_autoscaling ? 1 : 0
  name         = "${var.name}-red5-stream-manager-server"
  machine_type = var.stream_manager_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type = "pd-ssd"
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  provisioner "file" {
    source      = var.path_to_google_cloud_controller
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_google_cloud_controller)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_API_KEY='${var.stream_manager_api_key}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_PREFIX_NAME='${var.name}-node'",
      "export SSL_ENABLE='${var.https_letsencrypt_enable}'",
      "export SSL_DOMAIN='${var.https_letsencrypt_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_letsencrypt_certificate_email}'",
      "export SSL_PASSWORD='${var.https_letsencrypt_certificate_password}'",
      "export DB_LOCAL_ENABLE='${local.mysql_local_enable}'",
      "export DB_HOST='${local.mysql_host}'",
      "export DB_PORT='${var.mysql_port}'",
      "export DB_USER='${var.mysql_username}'",
      "export DB_PASSWORD='${nonsensitive(var.mysql_password)}'",
      "export GOGOLE_PROJECT_ID='${local.google_cloud_project}'",
      "export GOOGLE_DEFAULT_ZONE_ID='${self.zone}'",
      "export GOOGLE_VPC_NETWORK_NAME='${local.vpc_network_name}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_mysql_local.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_stream_manager.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

################################################################################
# MySQL Database Configuration
################################################################################
resource "google_sql_database_instance" "mysql_database" {
  count               = local.mysql_db_system_create ? 1 : 0
  name                = "${var.name}-mysql-database"
  database_version    = "MYSQL_8_0"
  region              = var.google_region
  project             = local.google_cloud_project
  root_password       = var.mysql_password
  deletion_protection = false
  settings {
    tier              = var.mysql_instance_type
    edition           = "ENTERPRISE"
    availability_type = "REGIONAL"
    disk_autoresize   = true

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = local.vpc_network_name
      require_ssl     = false

      authorized_networks {
        name          = "SM-Connection"
        value         = "0.0.0.0/0"
      }
    }
    location_preference {
      zone            = element(data.google_compute_zones.available_zone.names, count.index)
    }
  }
}

# Creating MySQL Database user
resource "google_sql_user" "default" {
  count               = local.mysql_db_system_create ? 1 : 0
  name                = var.mysql_username
  instance            = google_sql_database_instance.mysql_database[0].name
  password            = var.mysql_password
  project             = local.google_cloud_project
}

################################################################################
# Red5 Node Server Configuration
################################################################################
# Create security group for nodes
resource "google_compute_firewall" "red5_node_firewall" {
  count         = local.cluster_or_autoscaling && var.origin_image_create ? 1 : 0
  name          = "${var.name}-red5-node-firewall"
  network       = local.vpc_network_name
  priority      = 1000
  allow {
    protocol    = "icmp"
  }
  allow {
    protocol    = "tcp"
    ports       = var.red5_node_firewall_tcp_ports
  }
  allow {
    protocol    = "udp"
    ports       = var.red5_node_firewall_udp_ports
  }
  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
}

# Red5 Pro Origin server instance
resource "google_compute_instance" "red5_origin_server" {
  count        = var.origin_image_create ? 1 : 0
  name         = "${var.name}-red5-origin-server"
  machine_type = var.origin_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type  = var.origin_server_boot_disk_type
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.origin_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.origin_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.origin_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.origin_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.origin_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.origin_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.origin_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.origin_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.origin_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.origin_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.origin_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "export NODE_CLOUDSTORAGE_ENABLE='${var.origin_red5pro_cloudstorage_enable}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_ACCESS_KEY='${var.origin_red5pro_google_storage_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_SECRET_ACCESS_KEY='${var.origin_red5pro_google_storage_secret_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_BUCKET_NAME='${var.origin_red5pro_google_storage_bucket_name}'",
      "export NODE_CLOUDSTORAGE_POSTPROCESSOR_ENABLE='${var.origin_red5pro_cloudstorage_postprocessor_enable}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

# Red5 Pro Edge server instance
resource "google_compute_instance" "red5_edge_server" {
  count        = var.edge_image_create ? 1 : 0
  name         = "${var.name}-red5-edge-server"
  machine_type = var.edge_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type  = var.edge_server_boot_disk_type
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.edge_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.edge_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.edge_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.edge_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.edge_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.edge_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.edge_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.edge_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.edge_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.edge_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.edge_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

# Red5 Pro Transcoder server instance
resource "google_compute_instance" "red5_transcoder_server" {
  count        = var.transcoder_image_create ? 1 : 0
  name         = "${var.name}-red5-transcoder-server"
  machine_type = var.transcoder_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type  = var.transcoder_server_boot_disk_type
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.transcoder_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.transcoder_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.transcoder_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.transcoder_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.transcoder_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.transcoder_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.transcoder_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.transcoder_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.transcoder_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.transcoder_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.transcoder_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "export NODE_CLOUDSTORAGE_ENABLE='${var.transcoder_red5pro_cloudstorage_enable}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_ACCESS_KEY='${var.transcoder_red5pro_google_storage_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_SECRET_ACCESS_KEY='${var.transcoder_red5pro_google_storage_secret_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_BUCKET_NAME='${var.transcoder_red5pro_google_storage_bucket_name}'",
      "export NODE_CLOUDSTORAGE_POSTPROCESSOR_ENABLE='${var.transcoder_red5pro_cloudstorage_postprocessor_enable}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

# Red5 Pro Relay server instance
resource "google_compute_instance" "red5_relay_server" {
  count        = var.relay_image_create ? 1 : 0
  name         = "${var.name}-red5-relay-server"
  machine_type = var.relay_server_instance_type
  zone         = element(data.google_compute_zones.available_zone.names, count.index)
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
      type  = var.relay_server_boot_disk_type
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${local.private_ssh_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.relay_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.relay_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.relay_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.relay_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.relay_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.relay_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.relay_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.relay_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.relay_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.relay_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.relay_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${local.private_ssh_key}"
    }
  }
}

#################################################################################################
# Stop droplet which used for creating nodes(Origin, Edge, Transcoder, Relay) images (Gcloud CLI)
#################################################################################################
# Stop Origin node virtual machine Gcloud CLI
resource "null_resource" "delete_origin_node" {
  count        = var.origin_image_create ? 1 : 0
  provisioner "local-exec" {
    command    = "gcloud compute instances delete ${google_compute_instance.red5_origin_server[0].name} --zone=${google_compute_instance.red5_origin_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on   = [google_compute_instance.red5_origin_server[0]]
}

# Stop Edge node virtual machine Gcloud CLI
resource "null_resource" "delete_edge_node" {
  count        = var.edge_image_create ? 1 : 0
  provisioner "local-exec" {
    command    = "gcloud compute instances delete ${google_compute_instance.red5_edge_server[0].name} --zone=${google_compute_instance.red5_edge_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on   = [google_compute_instance.red5_edge_server[0]]
}

# Stop Transcoder node virtual machine Gcloud CLI
resource "null_resource" "delete_transcoder_node" {
  count        = var.transcoder_image_create ? 1 : 0
  provisioner "local-exec" {
    command    = "gcloud compute instances delete ${google_compute_instance.red5_transcoder_server[0].name} --zone=${google_compute_instance.red5_transcoder_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on   = [google_compute_instance.red5_transcoder_server[0]]
}

# Stop Relay node virtual machine Gcloud CLI
resource "null_resource" "delete_relay_node" {
  count        = var.relay_image_create ? 1 : 0
  provisioner "local-exec" {
    command    = "gcloud compute instances delete ${google_compute_instance.red5_relay_server[0].name} --zone=${google_compute_instance.red5_relay_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on   = [google_compute_instance.red5_relay_server[0]]
}

####################################################################################################
# Red5 Pro Autoscaling Nodes create images - Origin/Edge/Transcoders/Relay
####################################################################################################
# Origin Node - Origin Image
resource "google_compute_image" "red5_origin_image" {
  count        = var.origin_image_create ? 1 : 0
  name         = "${var.name}-origin-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project      = local.google_cloud_project
  source_disk  = google_compute_instance.red5_origin_server[0].boot_disk.0.source
  depends_on   = [null_resource.delete_origin_node[0]]

  lifecycle {
    ignore_changes = [name]
  }
}

# Edge Node - Edge Image
resource "google_compute_image" "red5_edge_image" {
  count        = var.edge_image_create ? 1 : 0
  name         = "${var.name}-edge-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project      = local.google_cloud_project
  source_disk  = google_compute_instance.red5_edge_server[0].boot_disk.0.source
  depends_on   = [null_resource.delete_edge_node[0]]

  lifecycle {
    ignore_changes = [name]
  }
}

# Transcoder Node - Transcoder Image
resource "google_compute_image" "red5_transcoder_image" {
  count        = var.transcoder_image_create ? 1 : 0
  name         = "${var.name}-transcoder-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project      = local.google_cloud_project
  source_disk  = google_compute_instance.red5_transcoder_server[0].boot_disk.0.source
  depends_on   = [null_resource.delete_transcoder_node[0]]

  lifecycle {
    ignore_changes = [name]
  }
}

# Relay Node - Relay Image
resource "google_compute_image" "red5_relay_image" {
  count        = var.relay_image_create ? 1 : 0
  name         = "${var.name}-relay-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project      = local.google_cloud_project
  source_disk  = google_compute_instance.red5_relay_server[0].boot_disk.0.source
  depends_on   = [null_resource.delete_relay_node[0]]

  lifecycle {
    ignore_changes = [name]
  }
}

################################################################################
# Create/Delete node group (Stream Manager API)
################################################################################
resource "time_sleep" "wait_for_delete_nodegroup" {
  count      = var.node_group_create ? 1 : 0
  depends_on = [
    google_compute_firewall.red5_stream_manager_firewall[0],
    google_compute_instance.red5_stream_manager_server[0],
    google_compute_network.vpc_red5_network[0],
  ]
  
  destroy_duration = "2m"
}

resource "null_resource" "node_group" {
  count           = var.node_group_create ? 1 : 0
  triggers = {
    trigger_name  = "node-group-trigger"
    SM_IP         = "${local.stream_manager_ip}"
    SM_API_KEY    = "${var.stream_manager_api_key}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_delete_node_group.sh '${self.triggers.SM_IP}' '${self.triggers.SM_API_KEY}'"
  }

  provisioner "local-exec" {
    when    = create
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_create_node_group.sh"
    environment = {
      NAME                       = "${var.name}"
      SM_IP                      = "${local.stream_manager_ip}"
      SM_API_KEY                 = "${var.stream_manager_api_key}"
      NODE_GROUP_REGION          = "${var.google_region}"
      NODE_GROUP_NAME            = "${var.node_group_name}"
      ORIGINS                    = "${var.node_group_origins}"
      EDGES                      = "${var.node_group_edges}"
      TRANSCODERS                = "${var.node_group_transcoders}"
      RELAYS                     = "${var.node_group_relays}"
      ORIGIN_INSTANCE_TYPE       = "${var.node_group_origins_instance_type}"
      EDGE_INSTANCE_TYPE         = "${var.node_group_edges_instance_type}"
      TRANSCODER_INSTANCE_TYPE   = "${var.node_group_transcoders_instance_type}"
      RELAY_INSTANCE_TYPE        = "${var.node_group_relays_instance_type}"
      ORIGIN_CAPACITY            = "${var.node_group_origins_capacity}"
      EDGE_CAPACITY              = "${var.node_group_edges_capacity}"
      TRANSCODER_CAPACITY        = "${var.node_group_transcoders_capacity}"
      RELAY_CAPACITY             = "${var.node_group_relays_capacity}"
      ORIGIN_IMAGE_NAME          = "${try(google_compute_image.red5_origin_image[0].name, null)}"
      EDGE_IMAGE_NAME            = "${try(google_compute_image.red5_edge_image[0].name, null)}"
      TRANSCODER_IMAGE_NAME      = "${try(google_compute_image.red5_transcoder_image[0].name, null)}"
      RELAY_IMAGE_NAME           = "${try(google_compute_image.red5_relay_image[0].name, null)}"
    }
  }

  depends_on =  [ time_sleep.wait_for_delete_nodegroup[0] ]
}
