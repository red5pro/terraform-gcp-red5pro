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
  service                    = "iam.googleapis.com"
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
  project                 = local.google_cloud_project
  region                  = var.google_region
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

# create instance
resource "google_compute_instance" "red5_single_server" {
  count        = local.single ? 1 : 0
  name         = "${var.name}-red5-single-server"
  machine_type = var.single_server_instance_type
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

  tags = [var.name]
}
