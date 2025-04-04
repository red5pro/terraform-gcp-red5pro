locals {
  standalone                      = var.type == "standalone" ? true : false
  cluster                         = var.type == "cluster" ? true : false
  autoscale                       = var.type == "autoscale" ? true : false
  cluster_or_autoscale            = local.cluster || local.autoscale ? true : false
  google_cloud_project            = data.google_project.existing_gcp_project.project_id
  ssh_public_key                  = var.ssh_key_use_existing ? file(var.ssh_key_public_key_path_existing) : tls_private_key.red5pro_ssh_key[0].public_key_openssh
  ssh_private_key                 = var.ssh_key_use_existing ? file(var.ssh_key_private_key_path_existing) : tls_private_key.red5pro_ssh_key[0].private_key_pem
  ssh_private_key_path            = var.ssh_key_use_existing ? var.ssh_key_private_key_path_existing : local_file.red5pro_ssh_key_pem[0].filename
  vpc_network_name                = var.vpc_use_existing ? data.google_compute_network.existing_vpc_network[0].name : google_compute_network.vpc_red5_network[0].name
  standalone_server_ip            = local.standalone ? google_compute_instance.red5_standalone_server[0].network_interface.0.access_config.0.nat_ip : ""
  standalone_server_firewall      = local.standalone ? var.vpc_use_existing && var.firewall_standalone_network_tags_use_existing ? false : true : false
  standalone_server_firewall_tags = local.standalone_server_firewall ? ["${var.name}-standalone-tag"] : var.firewall_standalone_network_tags_existing
  stream_manager_firewall         = local.cluster_or_autoscale ? var.vpc_use_existing && var.firewall_stream_manager_network_tags_use_existing ? false : true : false
  stream_manager_firewall_tags    = local.stream_manager_firewall ? ["${var.name}-sm-tag"] : var.firewall_stream_manager_network_tags_existing
  stream_manager_nat_ip           = local.cluster ? var.stream_manager_reserved_ip_use_existing ? data.google_compute_address.existing_sm_reserved_ip[0].address : google_compute_address.sm_reserved_ip[0].address : ""
  stream_manager_ip               = local.autoscale ? local.lb_ip_address : local.cluster ? local.stream_manager_nat_ip : ""
  stream_manager_ssl              = local.autoscale ? "none" : var.https_ssl_certificate
  stream_manager_standalone       = local.autoscale ? false : true
  lb_ip_address                   = local.autoscale ? var.lb_global_reserved_ip_use_existing ? data.google_compute_global_address.existing_lb_reserved_ip[0].address : google_compute_global_address.lb_reserved_ip[0].address : ""
  red5_node_firewall              = local.cluster_or_autoscale && var.vpc_use_existing && var.firewall_nodes_network_tags_use_existing ? false : true
  red5_node_firewall_tags         = local.red5_node_firewall ? ["${var.name}-node-tag"] : var.firewall_nodes_network_tags_existing
  kafka_ip                        = local.cluster_or_autoscale ? local.kafka_standalone_instance ? google_compute_instance.red5pro_kafka_standalone[0].network_interface.0.network_ip : google_compute_instance.red5_stream_manager_server[0].network_interface.0.network_ip : null
  kafka_on_sm_replicas            = local.kafka_standalone_instance ? 0 : 1
  kafka_ssl_keystore_key          = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", trimspace(tls_private_key.kafka_server_key[0].private_key_pem_pkcs8)))) : null
  kafka_ssl_truststore_cert       = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", tls_self_signed_cert.ca_cert[0].cert_pem))) : null
  kafka_ssl_keystore_cert_chain   = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", tls_locally_signed_cert.kafka_server_cert[0].cert_pem))) : null
  kafka_standalone_firewall       = local.cluster_or_autoscale && local.kafka_standalone_instance ? var.vpc_use_existing && var.firewall_kafka_network_tags_use_existing ? false : true : false
  kafka_standalone_firewall_tags  = local.kafka_standalone_firewall ? ["${var.name}-kafka-tag"] : var.firewall_kafka_network_tags_existing
  kafka_standalone_instance       = local.autoscale ? true : local.cluster && var.kafka_standalone_instance_create ? true : false
  ubuntu_image                    = lookup(var.ubuntu_images_gcp, var.ubuntu_version, "what?")
}

################################################################################
# Google Cloud Project
################################################################################
# Existing google project of google cloud account
data "google_project" "existing_gcp_project" {
  project_id = var.google_project_id
}

################################################################################
# SSH_KEY
################################################################################
# SSH key pair generation
resource "tls_private_key" "red5pro_ssh_key" {
  count     = var.ssh_key_use_existing ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH private key to local folder
resource "local_file" "red5pro_ssh_key_pem" {
  count           = var.ssh_key_use_existing ? 0 : 1
  filename        = "./${var.name}-ssh.pem"
  content         = tls_private_key.red5pro_ssh_key[0].private_key_pem
  file_permission = "0400"
}

# Save SSH public key to local folder
resource "local_file" "red5pro_ssh_key_pub" {
  count    = var.ssh_key_use_existing ? 0 : 1
  filename = "./${var.name}-ssh.pub"
  content  = tls_private_key.red5pro_ssh_key[0].public_key_openssh
}

################################################################################
# VPC and Network Configuration
################################################################################
# Create VPC
resource "google_compute_network" "vpc_red5_network" {
  count                           = var.vpc_use_existing ? 0 : 1
  name                            = "${var.name}-vpc"
  project                         = local.google_cloud_project
  auto_create_subnetworks         = true
  delete_default_routes_on_create = false
}

# Get existing VPC
data "google_compute_network" "existing_vpc_network" {
  count   = var.vpc_use_existing ? 1 : 0
  name    = var.vpc_name_existing
  project = local.google_cloud_project
}

# Get available zones
data "google_compute_zones" "available_zone" {
  region  = var.google_region
  project = local.google_cloud_project
  status  = "UP"
}

################################################################################
# Red5 Standalone Server Configuration
################################################################################
# Create security group for Red5 Standalone server
resource "google_compute_firewall" "red5_standalone_firewall" {
  count   = local.standalone_server_firewall ? 1 : 0
  name    = "${var.name}-standalone-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.red5_standalone_firewall_tcp_ports
  }

  allow {
    protocol = "udp"
    ports    = var.red5_standlaone_firewall_udp_ports
  }

  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
  target_tags   = local.standalone_server_firewall_tags
}

# Create security group for Red5 Standalone server SSH
resource "google_compute_firewall" "red5_standalone_ssh_firewall" {
  count   = local.standalone && local.standalone_server_firewall ? 1 : 0
  name    = "${var.name}-standalone-ssh-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.firewall_ssh_allowed_ip_ranges
  project       = local.google_cloud_project
  target_tags   = local.standalone_server_firewall_tags
}

resource "random_password" "ssl_password_red5pro_standalone" {
  count   = local.standalone && var.https_ssl_certificate != "none" ? 1 : 0
  length  = 16
  special = false
}

# Red5 Pro standalone server instance
resource "google_compute_instance" "red5_standalone_server" {
  count        = local.standalone ? 1 : 0
  name         = "${var.name}-standalone-server"
  machine_type = var.standalone_instance_type
  zone         = data.google_compute_zones.available_zone.names[0]
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = local.ubuntu_image
      type  = var.standalone_disk_type
      size  = var.standalone_disk_size
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
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
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.standalone_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.standalone_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.standalone_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.standalone_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.standalone_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.standalone_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.standalone_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.standalone_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.standalone_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.standalone_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.standalone_red5pro_round_trip_auth_endpoint_invalidate}'",
      "export NODE_CLOUDSTORAGE_ENABLE='${var.standalone_red5pro_cloudstorage_enable}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_ACCESS_KEY='${var.standalone_red5pro_google_storage_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_SECRET_ACCESS_KEY='${var.standalone_red5pro_google_storage_secret_access_key}'",
      "export NODE_CLOUDSTORAGE_GOOGLE_STORAGE_BUCKET_NAME='${var.standalone_red5pro_google_storage_bucket_name}'",
      "export NODE_CLOUDSTORAGE_POSTPROCESSOR_ENABLE='${var.standalone_red5pro_cloudstorage_postprocessor_enable}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sudo mkdir -p /usr/local/red5pro/certs",
      "echo '${try(file(var.https_ssl_certificate_cert_path), "")}' | sudo tee -a /usr/local/red5pro/certs/fullchain.pem",
      "echo '${try(file(var.https_ssl_certificate_key_path), "")}' | sudo tee -a /usr/local/red5pro/certs/privkey.pem",
      "export SSL='${var.https_ssl_certificate}'",
      "export SSL_DOMAIN='${var.https_ssl_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_ssl_certificate_email}'",
      "export SSL_PASSWORD='${try(nonsensitive(random_password.ssl_password_red5pro_standalone[0].result), "")}'",
      "export SSL_CERT_PATH=/usr/local/red5pro/certs",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }
  tags = local.standalone_server_firewall_tags
}

################################################################################
# Red5 Stream Manager Server Configuration
################################################################################
# Create security group for Stream Manager
resource "google_compute_firewall" "red5_stream_manager_firewall" {
  count   = local.cluster_or_autoscale && local.stream_manager_firewall ? 1 : 0
  name    = "${var.name}-stream-manager-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.red5_stream_manager_firewall_tcp_ports
  }
  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
  target_tags   = local.stream_manager_firewall_tags
}

# Create security group for Stream Sanager SSH
resource "google_compute_firewall" "red5_stream_manager_ssh_firewall" {
  count   = local.cluster_or_autoscale && local.stream_manager_firewall ? 1 : 0
  name    = "${var.name}-stream-manager-ssh-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.firewall_ssh_allowed_ip_ranges
  project       = local.google_cloud_project
  target_tags   = local.stream_manager_firewall_tags
}

# Reserved IP address for Stream Manager
resource "google_compute_address" "sm_reserved_ip" {
  count        = local.cluster && var.stream_manager_reserved_ip_use_existing == false ? 1 : 0
  name         = "${var.name}-sm-reserver-ip"
  address_type = "EXTERNAL"
  project      = local.google_cloud_project
  region       = var.google_region
}

# Already created reserved IP for Stream Manager
data "google_compute_address" "existing_sm_reserved_ip" {
  count   = local.cluster && var.stream_manager_reserved_ip_use_existing ? 1 : 0
  name    = var.stream_manager_reserved_ip_name_existing
  project = local.google_cloud_project
  region  = var.google_region
  lifecycle {
    postcondition {
      condition     = self.address != null
      error_message = "The existing IP address with name: ${var.stream_manager_reserved_ip_name_existing} does not exist in region ${var.google_region}."
    }
  }
}

# Generate random password for Red5 Pro Stream Manager 2.0 authentication
resource "random_password" "r5as_auth_secret" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 32
  special = false
}

# Red5 Pro Stream Manager Instance
resource "google_compute_instance" "red5_stream_manager_server" {
  count                     = local.cluster_or_autoscale ? 1 : 0
  name                      = local.autoscale ? "${var.name}-stream-manager-image" : "${var.name}-stream-manager"
  machine_type              = var.stream_manager_instance_type
  zone                      = data.google_compute_zones.available_zone.names[0]
  project                   = local.google_cloud_project
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = local.ubuntu_image
      type  = var.stream_manager_disk_type
      size  = var.stream_manager_disk_size
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
      nat_ip = local.autoscale ? null : local.stream_manager_nat_ip
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu/"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = local.ssh_private_key
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    mkdir -p /usr/local/stream-manager/certs
    echo "${try(file(var.https_ssl_certificate_cert_path), "")}" > /usr/local/stream-manager/certs/cert.pem
    echo "${try(file(var.https_ssl_certificate_key_path), "")}" > /usr/local/stream-manager/certs/privkey.pem
    ############################ .env file #########################################################
    cat >> /usr/local/stream-manager/.env <<- EOM
    KAFKA_CLUSTER_ID=${random_id.kafka_cluster_id[0].b64_std}
    KAFKA_ADMIN_USERNAME=${random_string.kafka_admin_username[0].result}
    KAFKA_ADMIN_PASSWORD=${random_id.kafka_admin_password[0].id}
    KAFKA_CLIENT_USERNAME=${random_string.kafka_client_username[0].result}
    KAFKA_CLIENT_PASSWORD=${random_id.kafka_client_password[0].id}
    R5AS_AUTH_SECRET=${random_password.r5as_auth_secret[0].result}
    R5AS_AUTH_USER=${var.stream_manager_auth_user}
    R5AS_AUTH_PASS=${var.stream_manager_auth_password}
    R5AS_PROXY_USER=${random_string.proxy_admin_username[0].result}
    R5AS_PROXY_PASS=${random_id.proxy_admin_password[0].id}
    TF_VAR_gcp_project_id=${var.google_project_id}
    TF_VAR_r5p_license_key=${var.red5pro_license_key}
    TRAEFIK_TLS_CHALLENGE=${local.stream_manager_ssl == "letsencrypt" ? "true" : "false"}
    TRAEFIK_HOST=${var.https_ssl_certificate_domain_name}
    TRAEFIK_SSL_EMAIL=${var.https_ssl_certificate_email}
    TRAEFIK_CMD=${local.stream_manager_ssl == "imported" ? "--providers.file.filename=/scripts/traefik.yaml" : ""}
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = all
  }

  tags       = local.stream_manager_firewall_tags
  depends_on = [google_compute_address.sm_reserved_ip, data.google_compute_address.existing_sm_reserved_ip]
}

resource "null_resource" "red5pro_sm_configuration" {
  count = local.cluster_or_autoscale ? 1 : 0

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -F",
      "sudo cloud-init status --wait",
      "echo 'KAFKA_SSL_KEYSTORE_KEY=${local.kafka_ssl_keystore_key}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_SSL_TRUSTSTORE_CERTIFICATES=${local.kafka_ssl_truststore_cert}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_SSL_KEYSTORE_CERTIFICATE_CHAIN=${local.kafka_ssl_keystore_cert_chain}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_REPLICAS=${local.kafka_on_sm_replicas}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_IP=${local.kafka_ip}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'TRAEFIK_IP=${local.stream_manager_ip}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'TF_VAR_gcp_node_network_tag=${jsonencode(local.red5_node_firewall_tags)}' | sudo tee -a /usr/local/stream-manager/.env",
      "export SM_SSL='${local.stream_manager_ssl}'",
      "export SM_STANDALONE='${local.stream_manager_standalone}'",
      "export SM_SSL_DOMAIN='${var.https_ssl_certificate_domain_name}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_sm2_gcp.sh",
    ]
    connection {
      host        = google_compute_instance.red5_stream_manager_server[0].network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }
  depends_on = [tls_cert_request.kafka_server_csr, null_resource.red5pro_kafka_standalone_configuration]
}

################################################################################
# Kafka keys and certificates
################################################################################

# Generate random admin usernames for Kafka cluster
resource "random_string" "kafka_admin_username" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}
resource "random_string" "proxy_admin_username" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Generate random client usernames for Kafka cluster
resource "random_string" "kafka_client_username" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Generate random IDs for Kafka cluster
resource "random_id" "kafka_cluster_id" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Generate random passwords for Kafka cluster
resource "random_id" "kafka_admin_password" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}
resource "random_id" "proxy_admin_password" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Generate random passwords for Kafka cluster
resource "random_id" "kafka_client_password" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Create private key for CA
resource "tls_private_key" "ca_private_key" {
  count     = local.cluster_or_autoscale ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create private key for kafka server certificate 
resource "tls_private_key" "kafka_server_key" {
  count     = local.cluster_or_autoscale ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create self-signed certificate for CA
resource "tls_self_signed_cert" "ca_cert" {
  count             = local.cluster_or_autoscale ? 1 : 0
  private_key_pem   = tls_private_key.ca_private_key[0].private_key_pem
  is_ca_certificate = true

  subject {
    country             = "US"
    common_name         = "Infrared5, Inc."
    organization        = "Red5"
    organizational_unit = "Red5 Root Certification Auhtority"
  }

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
    "crl_signing",
  ]
}

# Create CSR for server certificate 
resource "tls_cert_request" "kafka_server_csr" {
  count           = local.cluster_or_autoscale ? 1 : 0
  private_key_pem = tls_private_key.kafka_server_key[0].private_key_pem
  ip_addresses    = [local.kafka_ip]
  dns_names       = ["kafka0"]

  subject {
    country             = "US"
    common_name         = "Kafka server"
    organization        = "Infrared5, Inc."
    organizational_unit = "Development"
  }

  depends_on = [google_compute_instance.red5_stream_manager_server[0], google_compute_instance.red5pro_kafka_standalone[0]]
}

# Sign kafka server Certificate by Private CA 
resource "tls_locally_signed_cert" "kafka_server_cert" {
  count              = local.cluster_or_autoscale ? 1 : 0
  cert_request_pem   = tls_cert_request.kafka_server_csr[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_private_key[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert[0].cert_pem

  validity_period_hours = 1 * 365 * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "google_compute_instance" "red5pro_kafka_standalone" {
  count        = local.kafka_standalone_instance ? 1 : 0
  name         = "${var.name}-red5-kafka-standalone"
  machine_type = var.kafka_standalone_instance_type
  zone         = data.google_compute_zones.available_zone.names[0]
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = local.ubuntu_image
      type  = var.kafka_standalone_disk_type
      size  = var.kafka_standalone_disk_size
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
  tags = local.kafka_standalone_firewall_tags
}

resource "null_resource" "red5pro_kafka_standalone_configuration" {
  count = local.kafka_standalone_instance ? 1 : 0

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = google_compute_instance.red5pro_kafka_standalone[0].network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -F",
      "sudo cloud-init status --wait",
      "echo 'ssl.keystore.key=${local.kafka_ssl_keystore_key}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'ssl.truststore.certificates=${local.kafka_ssl_truststore_cert}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'ssl.keystore.certificate.chain=${local.kafka_ssl_keystore_cert_chain}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'listener.name.broker.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${nonsensitive(random_string.kafka_admin_username[0].result)}\" password=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_admin_username[0].result)}=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_client_username[0].result)}=\"${nonsensitive(random_id.kafka_client_password[0].id)}\";' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'listener.name.controller.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${nonsensitive(random_string.kafka_admin_username[0].result)}\" password=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_admin_username[0].result)}=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_client_username[0].result)}=\"${nonsensitive(random_id.kafka_client_password[0].id)}\";' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'advertised.listeners=BROKER://${local.kafka_ip}:9092' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "export KAFKA_ARCHIVE_URL='${var.kafka_standalone_instance_arhive_url}'",
      "export KAFKA_CLUSTER_ID='${random_id.kafka_cluster_id[0].b64_std}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_kafka_install.sh",
    ]

    connection {
      host        = google_compute_instance.red5pro_kafka_standalone[0].network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  depends_on = [tls_cert_request.kafka_server_csr]
}

# Create security group for Kafka Standalone server
resource "google_compute_firewall" "kafka_standalone_firewall" {
  count   = local.kafka_standalone_instance && local.kafka_standalone_firewall ? 1 : 0
  name    = "${var.name}-kafka-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.kafka_standalone_firewall_ports
  }
  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
  target_tags   = local.kafka_standalone_firewall_tags
}

# Create security group for Stream Sanager SSH
resource "google_compute_firewall" "kafka_standalone_ssh_firewall" {
  count   = local.kafka_standalone_instance && local.kafka_standalone_firewall ? 1 : 0
  name    = "${var.name}-kafka-ssh-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.firewall_ssh_allowed_ip_ranges
  project       = local.google_cloud_project
  target_tags   = local.kafka_standalone_firewall_tags
}

################################################################################
# Load Balancer Configuration
################################################################################
# Reserved IP address for Load Balancer
resource "google_compute_global_address" "lb_reserved_ip" {
  count        = local.autoscale && var.lb_global_reserved_ip_use_existing ? 0 : 1
  name         = "${var.name}-lb-reserver-ip"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
  project      = local.google_cloud_project
}

# Already created reserved IP for Stream Manager
data "google_compute_global_address" "existing_lb_reserved_ip" {
  count   = local.autoscale && var.lb_global_reserved_ip_use_existing ? 1 : 0
  name    = var.lb_global_reserved_ip_name_existing
  project = local.google_cloud_project
  lifecycle {
    postcondition {
      condition     = self.address != null
      error_message = "The existing IP address with name: ${var.lb_global_reserved_ip_name_existing} does not exist."
    }
  }
}

# New SSL cerificate for Load Balancer
resource "google_compute_ssl_certificate" "new_lb_ssl_cert" {
  count       = local.autoscale && var.https_ssl_certificate == "imported" ? 1 : 0
  name_prefix = var.https_ssl_certificate_name
  private_key = file(var.https_ssl_certificate_key_path)
  certificate = file(var.https_ssl_certificate_cert_path)
  project     = local.google_cloud_project
  lifecycle {
    create_before_destroy = true
  }
}

# Existing SSL cerificate for Load Balancer
data "google_compute_ssl_certificate" "existing_ssl_lb_cert" {
  count   = local.autoscale && var.https_ssl_certificate == "existing" ? 1 : 0
  name    = var.https_ssl_certificate_name
  project = local.google_cloud_project
}

# Template for Stream Manager
resource "google_compute_instance_template" "stream_manager_template" {
  count        = local.autoscale ? 1 : 0
  name         = "${var.name}-stream-manager"
  machine_type = var.stream_manager_instance_type
  tags         = local.stream_manager_firewall_tags
  project      = local.google_cloud_project
  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }

  disk {
    auto_delete  = true
    source_image = google_compute_image.red5_sm_image[0].self_link
    disk_type    = var.stream_manager_disk_type
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_image.red5_sm_image]
  lifecycle {
    ignore_changes = [disk]
  }
}

# Health check for stream Manager
resource "google_compute_health_check" "sm_health_check" {
  count               = local.autoscale ? 1 : 0
  name                = "${var.name}-sm-health-check"
  project             = local.google_cloud_project
  timeout_sec         = 5
  check_interval_sec  = 10
  healthy_threshold   = 5
  unhealthy_threshold = 5

  http_health_check {
    request_path = "/as/v1/admin/healthz"
    port         = 80
  }
}

# Autoscaler for Stream Manager
resource "google_compute_autoscaler" "stream_manager_autoscaler" {
  count  = local.autoscale ? 1 : 0
  name   = "${var.name}-sm-autoscaler"
  zone   = data.google_compute_zones.available_zone.names[0]
  target = google_compute_instance_group_manager.stream_manager_instance_group[0].id

  autoscaling_policy {
    min_replicas    = var.stream_manager_autoscaling_min_replicas
    max_replicas    = var.stream_manager_autoscaling_max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

# Instance Group Manager for Stream Manager
resource "google_compute_instance_group_manager" "stream_manager_instance_group" {
  count   = local.autoscale ? 1 : 0
  name    = "${var.name}-sm-instance-group-manager"
  zone    = data.google_compute_zones.available_zone.names[0]
  project = local.google_cloud_project

  named_port {
    name = "${var.name}-sm-http-port"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.stream_manager_template[0].self_link_unique
    name              = "${var.name}-sm-version"
  }
  base_instance_name = "${var.name}-stream-manager"

  auto_healing_policies {
    health_check      = google_compute_health_check.sm_health_check[0].id
    initial_delay_sec = 300
  }

  instance_lifecycle_policy {
    force_update_on_repair = "NO"
  }
}

# Backend service for Stream Manager
resource "google_compute_backend_service" "sm_backend_service" {
  count                 = local.autoscale ? 1 : 0
  name                  = "${var.name}-sm-backend-service"
  project               = local.google_cloud_project
  protocol              = "HTTP"
  port_name             = "${var.name}-sm-http-port"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 60
  enable_cdn            = false
  health_checks         = [google_compute_health_check.sm_health_check[0].id]
  backend {
    group           = google_compute_instance_group_manager.stream_manager_instance_group[0].instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Load Balancer URL map
resource "google_compute_url_map" "lb_url_map" {
  count           = local.autoscale ? 1 : 0
  name            = "${var.name}-load-balancer-map"
  project         = local.google_cloud_project
  default_service = google_compute_backend_service.sm_backend_service[0].id
}

# Load Balancer HTTP proxy
resource "google_compute_target_http_proxy" "lb_http_proxy" {
  count   = local.autoscale ? 1 : 0
  name    = "${var.name}-http-proxy"
  project = local.google_cloud_project
  url_map = google_compute_url_map.lb_url_map[0].id
}

# Load Balancer HTTP forwarding rule
resource "google_compute_global_forwarding_rule" "lb_http_forward_rule" {
  count                 = local.autoscale ? 1 : 0
  name                  = "${var.name}-forwarding-rule-http"
  project               = local.google_cloud_project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.lb_http_proxy[0].id
  ip_address            = local.lb_ip_address
}

# Load Balancer HTTPS proxy
resource "google_compute_target_https_proxy" "lb_https_proxy" {
  count            = local.autoscale && var.https_ssl_certificate != "none" ? 1 : 0
  name             = "${var.name}-https-proxy"
  project          = local.google_cloud_project
  url_map          = google_compute_url_map.lb_url_map[0].id
  ssl_certificates = [var.https_ssl_certificate == "imported" ? google_compute_ssl_certificate.new_lb_ssl_cert[0].id : var.https_ssl_certificate == "existing" ? data.google_compute_ssl_certificate.existing_ssl_lb_cert[0].id : null]
}

# Load Balancer forwarding rule
resource "google_compute_global_forwarding_rule" "lb_https_forward_rule" {
  count                 = local.autoscale && var.https_ssl_certificate != "none" ? 1 : 0
  name                  = "${var.name}-forwarding-rule-https"
  project               = local.google_cloud_project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.lb_https_proxy[0].id
  ip_address            = local.lb_ip_address
}

################################################################################
# Red5 Node Server Configuration
################################################################################
# Create security group for Nodes
resource "google_compute_firewall" "red5_node_firewall" {
  count   = local.cluster_or_autoscale && local.red5_node_firewall ? 1 : 0
  name    = "${var.name}-node-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.red5_node_firewall_tcp_ports
  }
  allow {
    protocol = "udp"
    ports    = var.red5_node_firewall_udp_ports
  }
  source_ranges = ["0.0.0.0/0"]
  project       = local.google_cloud_project
  target_tags   = local.red5_node_firewall_tags
}

# Create security group for Nodes SSH
resource "google_compute_firewall" "red5_node_ssh_firewall" {
  count   = local.cluster_or_autoscale && local.red5_node_firewall ? 1 : 0
  name    = "${var.name}-node-ssh-firewall"
  network = local.vpc_network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.firewall_ssh_allowed_ip_ranges
  project       = local.google_cloud_project
  target_tags   = local.red5_node_firewall_tags
}

# Red5 Pro Node image
resource "google_compute_instance" "red5_node_server" {
  count        = local.cluster_or_autoscale && var.node_image_create ? 1 : 0
  name         = "${var.name}-node-image"
  machine_type = var.node_image_instance_type
  zone         = data.google_compute_zones.available_zone.names[0]
  project      = local.google_cloud_project

  boot_disk {
    initialize_params {
      image = local.ubuntu_image
      type  = var.node_image_disk_type
      size  = var.node_image_disk_size
    }
  }

  network_interface {
    network = local.vpc_network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
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
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sleep 2"
    ]
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }
  lifecycle {
    ignore_changes = all
  }
  tags = local.red5_node_firewall_tags
}

#################################################################################################
# Stop instances which used for creating Node and Stream Manager images (Gcloud CLI)
#################################################################################################
# Stop Stream Manager virtual machine Gcloud CLI
resource "null_resource" "delete_stream_manager" {
  count = local.autoscale ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud compute instances delete ${google_compute_instance.red5_stream_manager_server[0].name} --zone=${google_compute_instance.red5_stream_manager_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on = [google_compute_instance.red5_stream_manager_server[0], null_resource.red5pro_sm_configuration[0]]
}

# Stop Node virtual machine Gcloud CLI
resource "null_resource" "delete_red5_node_instance" {
  count = local.cluster_or_autoscale && var.node_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud compute instances delete ${google_compute_instance.red5_node_server[0].name} --zone=${google_compute_instance.red5_node_server[0].zone} --keep-disks=all --quiet"
  }
  depends_on = [google_compute_instance.red5_node_server[0]]
}

#########################################################################################################
# Delete instances disk for creating images of Node and Stream Manager images (Gcloud CLI)
#########################################################################################################
# Delete Stream Manager virtual machine disk Gcloud CLI
resource "null_resource" "delete_stream_manager_disk" {
  count = local.autoscale ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud compute disks delete ${google_compute_instance.red5_stream_manager_server[0].name} --zone=${google_compute_instance.red5_stream_manager_server[0].zone} --quiet"
  }
  depends_on = [google_compute_image.red5_sm_image[0], null_resource.red5pro_sm_configuration[0]]
}

# Delete Origin node virtual machine disk Gcloud CLI
resource "null_resource" "delete_red5_node_disk" {
  count = local.cluster_or_autoscale && var.node_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud compute disks delete ${google_compute_instance.red5_node_server[0].name} --zone=${google_compute_instance.red5_node_server[0].zone} --quiet"
  }
  depends_on = [google_compute_image.red5_node_image[0]]
}

####################################################################################################
# Red5 Pro Autoscaling Nodes create images - Origin & Stream Manager
####################################################################################################
# Stream Manager Image
resource "google_compute_image" "red5_sm_image" {
  count       = local.autoscale ? 1 : 0
  name        = "${var.name}-sm-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project     = local.google_cloud_project
  source_disk = google_compute_instance.red5_stream_manager_server[0].boot_disk.0.source
  depends_on  = [null_resource.delete_stream_manager[0], null_resource.red5pro_sm_configuration[0]]

  lifecycle {
    ignore_changes = [name, source_disk]
  }
}

# Red5 Node - Image
resource "google_compute_image" "red5_node_image" {
  count       = var.node_image_create ? 1 : 0
  name        = "${var.name}-node-image-${formatdate("DDMMYY-hhmm", timestamp())}"
  project     = local.google_cloud_project
  source_disk = google_compute_instance.red5_node_server[0].boot_disk.0.source
  depends_on  = [null_resource.delete_red5_node_instance[0]]

  lifecycle {
    ignore_changes = [name, source_disk]
  }
}

################################################################################
# Create/Delete node group (Stream Manager API)
################################################################################
resource "time_sleep" "wait_for_delete_nodegroup" {
  count = local.cluster_or_autoscale && var.node_group_create ? 1 : 0
  depends_on = [
    google_compute_firewall.red5_stream_manager_firewall[0],
    google_compute_instance.red5_stream_manager_server[0],
    google_compute_network.vpc_red5_network[0],
    google_compute_instance_template.stream_manager_template[0],
    google_compute_health_check.sm_health_check[0],
    google_compute_instance_group_manager.stream_manager_instance_group[0],
    google_compute_backend_service.sm_backend_service[0],
    google_compute_url_map.lb_url_map[0],
    google_compute_target_http_proxy.lb_http_proxy[0],
    google_compute_global_forwarding_rule.lb_http_forward_rule[0],
    google_compute_global_forwarding_rule.lb_https_forward_rule[0],
    google_compute_target_https_proxy.lb_https_proxy[0],
    google_compute_instance.red5pro_kafka_standalone[0],
    null_resource.red5pro_kafka_standalone_configuration[0],
    null_resource.red5pro_sm_configuration[0],
    google_compute_firewall.kafka_standalone_firewall[0]
  ]
  destroy_duration = "120s"
}

resource "null_resource" "node_group" {
  count = local.cluster_or_autoscale && var.node_group_create ? 1 : 0
  triggers = {
    trigger_name   = "node-group-trigger"
    SM_IP          = "${local.stream_manager_ip}"
    R5AS_AUTH_USER = "${var.stream_manager_auth_user}"
    R5AS_AUTH_PASS = "${var.stream_manager_auth_password}"
  }
  provisioner "local-exec" {
    when    = create
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_create_node_group.sh"
    environment = {
      SM_IP                                    = "${local.stream_manager_ip}"
      R5AS_AUTH_USER                           = "${var.stream_manager_auth_user}"
      R5AS_AUTH_PASS                           = "${var.stream_manager_auth_password}"
      NODE_GROUP_REGION                        = "${var.google_region}"
      NODE_ENVIRONMENT                         = "${var.name}"
      NODE_VPC_NAME                            = "${local.vpc_network_name}"
      NODE_IMAGE_NAME                          = "${google_compute_image.red5_node_image[0].name}"
      ORIGINS_MIN                              = "${var.node_group_origins_min}"
      ORIGINS_MAX                              = "${var.node_group_origins_max}"
      ORIGIN_INSTANCE_TYPE                     = "${var.node_group_origins_instance_type}"
      ORIGIN_VOLUME_SIZE                       = "${var.node_group_origins_disk_size}"
      EDGES_MIN                                = "${var.node_group_edges_min}"
      EDGES_MAX                                = "${var.node_group_edges_max}"
      EDGE_INSTANCE_TYPE                       = "${var.node_group_edges_instance_type}"
      EDGE_VOLUME_SIZE                         = "${var.node_group_edges_disk_size}"
      TRANSCODERS_MIN                          = "${var.node_group_transcoders_min}"
      TRANSCODERS_MAX                          = "${var.node_group_transcoders_max}"
      TRANSCODER_INSTANCE_TYPE                 = "${var.node_group_transcoders_instance_type}"
      TRANSCODER_VOLUME_SIZE                   = "${var.node_group_transcoders_disk_size}"
      RELAYS_MIN                               = "${var.node_group_relays_min}"
      RELAYS_MAX                               = "${var.node_group_relays_max}"
      RELAY_INSTANCE_TYPE                      = "${var.node_group_relays_instance_type}"
      RELAY_VOLUME_SIZE                        = "${var.node_group_relays_disk_size}"
      PATH_TO_JSON_TEMPLATES                   = "${abspath(path.module)}/red5pro-installer/nodegroup-json-templates"
      NODE_ROUND_TRIP_AUTH_ENABLE              = "${var.node_config_round_trip_auth.enable}"
      NODE_ROUNT_TRIP_AUTH_TARGET_NODES        = "${join(",", var.node_config_round_trip_auth.target_nodes)}"
      NODE_ROUND_TRIP_AUTH_HOST                = "${var.node_config_round_trip_auth.auth_host}"
      NODE_ROUND_TRIP_AUTH_PORT                = "${var.node_config_round_trip_auth.auth_port}"
      NODE_ROUND_TRIP_AUTH_PROTOCOL            = "${var.node_config_round_trip_auth.auth_protocol}"
      NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE   = "${var.node_config_round_trip_auth.auth_endpoint_validate}"
      NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE = "${var.node_config_round_trip_auth.auth_endpoint_invalidate}"
      NODE_WEBHOOK_ENABLE                      = "${var.node_config_webhooks.enable}"
      NODE_WEBHOOK_TARGET_NODES                = "${join(",", var.node_config_webhooks.target_nodes)}"
      NODE_WEBHOOK_ENDPOINT                    = "${var.node_config_webhooks.webhook_endpoint}"
      NODE_SOCIAL_PUSHER_ENABLE                = "${var.node_config_social_pusher.enable}"
      NODE_SOCIAL_PUSHER_TARGET_NODES          = "${join(",", var.node_config_social_pusher.target_nodes)}"
      NODE_RESTREAMER_ENABLE                   = "${var.node_config_restreamer.enable}"
      NODE_RESTREAMER_TARGET_NODES             = "${join(",", var.node_config_restreamer.target_nodes)}"
      NODE_RESTREAMER_TSINGEST                 = "${var.node_config_restreamer.restreamer_tsingest}"
      NODE_RESTREAMER_IPCAM                    = "${var.node_config_restreamer.restreamer_ipcam}"
      NODE_RESTREAMER_WHIP                     = "${var.node_config_restreamer.restreamer_whip}"
      NODE_RESTREAMER_SRTINGEST                = "${var.node_config_restreamer.restreamer_srtingest}"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_delete_node_group.sh '${self.triggers.SM_IP}' '${self.triggers.R5AS_AUTH_USER}' '${self.triggers.R5AS_AUTH_PASS}'"
  }

  depends_on = [time_sleep.wait_for_delete_nodegroup[0]]

  lifecycle {
    precondition {
      condition     = var.node_image_create == true
      error_message = "ERROR! Node group creation requires the creation of a Node image for the node group. Please set the 'node_image_create' variable to 'true' and re-run the Terraform apply."
    }
  }
}
