variable "google_project_id" {
  description = "Google project to create resources of Red5 Pro"
  type        = string
  default     = ""
}
variable "google_region" {
  description = "Google Cloud region"
  type        = string
  default     = ""
}
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "The name value must be a valid! Example: example-name"
  }
}
variable "path_to_red5pro_build" {
  description = "Path to the Red5 Pro build zip file, absolute path or relative path. https://account.red5pro.com/downloads. Example: /home/ubuntu/red5pro-server-0.0.0.b0-release.zip"
  type        = string
  default     = ""
  validation {
    condition     = fileexists(var.path_to_red5pro_build) == true
    error_message = "The path_to_red5pro_build value must be a valid! Example: /home/ubuntu/red5pro-server-0.0.0.b0-release.zip"
  }
}
variable "type" {
  description = "Type of deployment: standalone, cluster, autoscale"
  type        = string
  default     = "standalone"
  validation {
    condition     = var.type == "standalone" || var.type == "cluster" || var.type == "autoscale"
    error_message = "The type value must be a valid! Example: standalone, cluster, autoscale"
  }
}

# SSH keys Configuration
variable "ssh_key_use_existing" {
  description = "Use existing SSH key pair or create a new one. true = use existing, false = create new SSH key pair"
  type        = bool
  default     = false
}
variable "ssh_key_public_key_path_existing" {
  description = "Existing public SSH key path"
  type        = string
  default     = ""
}
variable "ssh_key_private_key_path_existing" {
  description = "Existing private SSH key path"
  type        = string
  default     = ""
}

# VPC configuration
variable "vpc_use_existing" {
  description = "Use existing VPC network or create a new one. true = use existing, false = create new VPC network"
  type        = bool
  default     = false
}
variable "vpc_name_existing" {
  description = "Name of the existing VPC network if `vpc_use_existing` = true"
  type        = string
  default     = ""
}

# General Firewall configuration
variable "firewall_ssh_allowed_ip_ranges" {
  description = "List of IP ranges which allowed to SSH connection with Red5 Pro instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Ubuntu version Configuration
variable "ubuntu_version" {
  description = "Ubuntu version used for instances. Available: 18.04, 20.04 and 22.04"
  type        = string
  default     = "22.04"
  validation {
    condition     = var.ubuntu_version == "18.04" || var.ubuntu_version == "20.04" || var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, it can either be 18.04, 20.04 or 22.04"
  }
}
variable "ubuntu_images_gcp" {
  description = "AWS images for different ubuntu versions"
  type        = map(string)
  default = {
    18.04 = "ubuntu-os-cloud/ubuntu-1804-lts"
    20.04 = "ubuntu-os-cloud/ubuntu-2004-lts"
    22.04 = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

# Red5 Pro general configuration
variable "red5pro_license_key" {
  description = "Red5 Pro license key (https://www.red5pro.com/docs/installation/installation/license-key/)"
  type        = string
  default     = ""
}
variable "red5pro_api_enable" {
  description = "Red5 Pro Server API enable/disable (https://www.red5pro.com/docs/development/api/overview/)"
  type        = bool
  default     = true
}
variable "red5pro_api_key" {
  description = "Red5 Pro server API key"
  type        = string
  default     = ""
}

# Red5 Standalone Server Configuration
variable "red5_standalone_firewall_tcp_ports" {
  description = "The open required TCP for the Red5 Standalone server in Google cloud firewall"
  type        = list(string)
  default     = ["5080", "443", "80", "1935", "1936", "8554", "8000-8100"]
}
variable "red5_standlaone_firewall_udp_ports" {
  description = "The open required UDP for the Red5 Standalone server in Google cloud firewall"
  type        = list(string)
  default     = ["40000-65535", "8000-8100"]
}
variable "standalone_instance_type" {
  description = "Instance type for the standalone server"
  type        = string
  default     = ""
}
variable "standalone_disk_type" {
  description = "Boot disk type for Red5 Pro standalone server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = "pd-ssd"
}
variable "standalone_disk_size" {
  description = "Red5 Pro standalone server volume size"
  type        = number
  default     = 16
  validation {
    condition     = var.standalone_disk_size >= 8
    error_message = "The standalone_disk_size value must be a valid! Minimum 8"
  }
}
variable "standalone_red5pro_inspector_enable" {
  description = "Red5 Pro Standalone server Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_restreamer_enable" {
  description = "Red5 Pro Standalone server Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_socialpusher_enable" {
  description = "Red5 Pro Standalone server SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_suppressor_enable" {
  description = "Red5 Pro Standalone server Suppressor enable"
  type        = bool
  default     = false
}
variable "standalone_red5pro_hls_enable" {
  description = "Red5 Pro Standalone server HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_enable" {
  description = "Round trip authentication on the red5pro server enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_host" {
  description = "Round trip authentication server host"
  type        = string
  default     = ""
}
variable "standalone_red5pro_round_trip_auth_port" {
  description = "Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "standalone_red5pro_round_trip_auth_protocol" {
  description = "Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "standalone_red5pro_round_trip_auth_endpoint_validate" {
  description = "Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "standalone_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Google Cloud Video On Demand via Cloud Storage configuration
variable "standalone_red5pro_cloudstorage_enable" {
  description = "Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/google-cloud-platform-storage/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_google_storage_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage access key "
  type        = string
  default     = ""
}
variable "standalone_red5pro_google_storage_secret_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage secret access key"
  type        = string
  default     = ""
}
variable "standalone_red5pro_google_storage_bucket_name" {
  description = "Red5 Pro server cloud storage - Google Cloud storage bucket name"
  type        = string
  default     = ""
}
variable "standalone_red5pro_cloudstorage_postprocessor_enable" {
  description = "Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/)"
  type        = bool
  default     = false
}

# HTTPS/SSL variables for standalone/cluster/autoscale
variable "https_ssl_certificate" {
  description = "Enable SSL (HTTPS) on the Standalone Red5 Pro server or Stream Manager 2.0 server or Load Balancer"
  type        = string
  default     = "none"
  validation {
    condition     = var.https_ssl_certificate == "none" || var.https_ssl_certificate == "letsencrypt" || var.https_ssl_certificate == "imported" || var.https_ssl_certificate == "existing"
    error_message = "The https_ssl_certificate value must be a valid! Example: none, letsencrypt, imported, existing"
  }
}
variable "https_ssl_certificate_name" {
  description = "Name of the SSL certificate for the Stream Manager 2.0 Load Balancer (imported/existing)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_domain_name" {
  description = "Domain name for SSL certificate (letsencrypt/imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_email" {
  description = "Email for SSL certificate (letsencrypt)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_cert_path" {
  description = "Path to SSL certificate (imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_key_path" {
  description = "Path to SSL key (imported)"
  type        = string
  default     = ""
}

# Stream Manager Configuration
variable "stream_manager_auth_user" {
  description = "value to set the user name for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}
variable "stream_manager_auth_password" {
  description = "value to set the user password for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}
variable "red5_stream_manager_firewall_tcp_ports" {
  description = "The required port open for the Red5 Stream manager server in Google cloud firewall"
  type        = list(string)
  default     = ["9092", "443", "80"]
}
variable "stream_manager_instance_type" {
  description = "Instance type for the Stream Manager server"
  type        = string
  default     = ""
}
variable "stream_manager_disk_type" {
  description = "Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = "pd-ssd"
}
variable "stream_manager_disk_size" {
  description = "Stream Manager server boot size in GB. Minimum 16GB"
  type        = number
  default     = 24
  validation {
    condition     = var.stream_manager_disk_size >= 16
    error_message = "The stream_manager_disk_size value must be a valid! Minimum 16"
  }
}
variable "stream_manager_reserved_ip_use_existing" {
  description = "Use existing reserved IP for Stream Manager or create a new one"
  type        = bool
  default     = false
}
variable "stream_manager_reserved_ip_name_existing" {
  description = "Name of the existing reserved IP for Stream Manager"
  type        = string
  default     = ""
}

# Load Balancer configuration
variable "stream_manager_autoscaling_min_replicas" {
  description = "Minimum number of replicas for Stream Manager autoscaling"
  type        = number
  default     = 1
}
variable "stream_manager_autoscaling_max_replicas" {
  description = "Maximum number of replicas for Stream Manager autoscaling"
  type        = number
  default     = 2
}
variable "lb_global_reserved_ip_use_existing" {
  description = "Use existing Global Reserved IP address for Load Balancer"
  type        = bool
  default     = false
}
variable "lb_global_reserved_ip_name_existing" {
  description = "Name of the existing Global Reserved IP address for Load Balancer"
  type        = string
  default     = ""
}

# Red5 Pro Node Configuration
variable "red5_node_firewall_tcp_ports" {
  description = "The required port open for the Red5 node server in Google cloud firewall"
  type        = list(string)
  default     = ["5080", "80", "1935", "1936", "8554", "8000-8100"]
}
variable "red5_node_firewall_udp_ports" {
  description = "The required port open for the Red5 node server in Google cloud firewall"
  type        = list(string)
  default     = ["40000-65535", "8000-8100"]
}

# Red5 Pro Node Configuration
variable "node_image_create" {
  description = "Create new node image true/false. (Default:true) (https://www.red5pro.com/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "node_image_instance_type" {
  description = "Node image instance type"
  type        = string
  default     = ""
}
variable "node_image_disk_type" {
  description = "Boot disk type for node server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = "pd-ssd"
}
variable "node_image_disk_size" {
  description = "Node image - volume size"
  type        = number
  default     = 10
  validation {
    condition     = var.node_image_disk_size >= 10
    error_message = "The node_image_disk_size value must be a valid! Minimum 10"
  }
}

# Red5 Pro autoscaling Node group - (Optional) 
variable "node_group_create" {
  description = "Create new node group. Linux or Mac OS only."
  type        = bool
  default     = false
}
variable "node_group_origins_min" {
  description = "Number of minimum Origins"
  type        = number
  default     = 1
}
variable "node_group_origins_max" {
  description = "Number of maximum Origins"
  type        = number
  default     = 20
}
variable "node_group_origins_instance_type" {
  description = "Instance type for Origins"
  type        = string
  default     = ""
}
variable "node_group_origins_disk_size" {
  description = "Volume size in GB for Origins. Minimum 10GB"
  type        = number
  default     = 16
  validation {
    condition     = var.node_group_origins_disk_size >= 10
    error_message = "The node_group_origins_disk_size value must be a valid! Minimum 10"
  }
}
variable "node_group_edges_min" {
  description = "Number of minimum Edges"
  type        = number
  default     = 1
}
variable "node_group_edges_max" {
  description = "Number of maximum Edges"
  type        = number
  default     = 40
}
variable "node_group_edges_instance_type" {
  description = "Instance type for Edges"
  type        = string
  default     = ""
}
variable "node_group_edges_disk_size" {
  description = "Volume size in GB for Edges. Minimum 10GB"
  type        = number
  default     = 16
  validation {
    condition     = var.node_group_edges_disk_size >= 10
    error_message = "The node_group_edges_disk_size value must be a valid! Minimum 10"
  }
}
variable "node_group_transcoders_min" {
  description = "Number of minimum Transcoders"
  type        = number
  default     = 1
}
variable "node_group_transcoders_max" {
  description = "Number of maximum Transcoders"
  type        = number
  default     = 20
}
variable "node_group_transcoders_instance_type" {
  description = "Instance type for Transcoders"
  type        = string
  default     = ""
}
variable "node_group_transcoders_disk_size" {
  description = "Volume size in GB for Transcoders. Minimum 10GB"
  type        = number
  default     = 16
  validation {
    condition     = var.node_group_transcoders_disk_size >= 10
    error_message = "The node_group_transcoders_disk_size value must be a valid! Minimum 10"
  }
}
variable "node_group_relays_min" {
  description = "Number of minimum Relays"
  type        = number
  default     = 1
}
variable "node_group_relays_max" {
  description = "Number of maximum Relays"
  type        = number
  default     = 20
}
variable "node_group_relays_instance_type" {
  description = "Instance type for Relays"
  type        = string
  default     = ""
}
variable "node_group_relays_disk_size" {
  description = "Volume size in GB for Relays. Minimum 10GB"
  type        = number
  default     = 16
  validation {
    condition     = var.node_group_relays_disk_size >= 10
    error_message = "The node_group_relays_disk_size value must be a valid! Minimum 10"
  }
}

# Red5 Pro Kafka standlaone properties
variable "kafka_standalone_instance_create" {
  description = "Create a dedicated GCP instance for Red5 pro Kafka Standlaone"
  type        = bool
  default     = false
}
variable "kafka_standalone_instance_type" {
  description = "Red5 Pro Kafka Standalone server instance type"
  type        = string
  default     = "n2-standard-2"
}
variable "kafka_standalone_disk_type" {
  description = "Boot disk type for Kafka server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = "pd-ssd"
}
variable "kafka_standalone_firewall_ports" {
  description = "The required port open for the Kafka server in Google cloud firewall"
  type        = list(string)
  default     = ["9092"]
}
variable "kafka_standalone_disk_size" {
  description = "value to set the volume size for kafka"
  type        = number
  default     = 24
  validation {
    condition     = var.kafka_standalone_disk_size >= 10
    error_message = "The kafka_standalone_disk_size value must be a valid! Minimum 10"
  }
}
variable "kafka_standalone_instance_arhive_url" {
  description = "Kafka standalone instance - archive URL"
  type        = string
  default     = "https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz"
}

# Firewalls network tags configuration
variable "firewall_standalone_network_tags_use_existing" {
  description = "Use existing firewall network Tags for standalone Red5 Pro server"
  type        = bool
  default     = false
}
variable "firewall_standalone_network_tags_existing" {
  description = "Specify existing Firewall network Tags for Red5 Standalone Server instance"
  type        = list(string)
  default     = []
}
variable "firewall_stream_manager_network_tags_use_existing" {
  description = "Use existing firewall network Tags for Stream Manager"
  type        = bool
  default     = false
}
variable "firewall_stream_manager_network_tags_existing" {
  description = "Specify existing Firewall network Tags for Stream Manager instance"
  type        = list(string)
  default     = []
}
variable "firewall_kafka_network_tags_use_existing" {
  description = "Use existing firewall network Tags for Kafka Standalone"
  type        = bool
  default     = false
}
variable "firewall_kafka_network_tags_existing" {
  description = "Specify existing Firewall network Tags for Kafka Standalone instance"
  type        = list(string)
  default     = []
}
variable "firewall_nodes_network_tags_use_existing" {
  description = "Use existing firewall network Tags for Red5 Pro nodes"
  type        = bool
  default     = false
}
variable "firewall_nodes_network_tags_existing" {
  description = "Specify existing Firewall network Tags for Red5 Pro nodes. Supports only 1 network tag for Nodes in current SM2.0 version"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.firewall_nodes_network_tags_existing) < 2
    error_message = "The firewall_nodes_network_tags_existing supports only 1 network tag"
  }
}

# Extra configuration for Red5 Pro autoscaling nodes
variable "node_config_webhooks" {
  description = "Webhooks configuration - (Optional) https://www.red5.net/docs/special/webhooks/overview/"
  type = object({
    enable           = bool
    target_nodes     = list(string)
    webhook_endpoint = string
  })
  default = {
    enable           = false
    target_nodes     = []
    webhook_endpoint = ""
  }
}
variable "node_config_round_trip_auth" {
  description = "Round trip authentication configuration - (Optional) https://www.red5.net/docs/special/authplugin/simple-auth/"
  type = object({
    enable                   = bool
    target_nodes             = list(string)
    auth_host                = string
    auth_port                = number
    auth_protocol            = string
    auth_endpoint_validate   = string
    auth_endpoint_invalidate = string
  })
  default = {
    enable                   = false
    target_nodes             = []
    auth_host                = ""
    auth_port                = 443
    auth_protocol            = "https://"
    auth_endpoint_validate   = "/validateCredentials"
    auth_endpoint_invalidate = "/invalidateCredentials"
  }
}
variable "node_config_social_pusher" {
  description = "Social Pusher configuration - (Optional) https://www.red5.net/docs/development/social-media-plugin/rest-api/"
  type = object({
    enable       = bool
    target_nodes = list(string)
  })
  default = {
    enable       = false
    target_nodes = []
  }
}
variable "node_config_restreamer" {
  description = "Restreamer configuration - (Optional) https://www.red5.net/docs/special/restreamer/overview/"
  type = object({
    enable               = bool
    target_nodes         = list(string)
    restreamer_tsingest  = bool
    restreamer_ipcam     = bool
    restreamer_whip      = bool
    restreamer_srtingest = bool
  })
  default = {
    enable               = false
    target_nodes         = []
    restreamer_tsingest  = false
    restreamer_ipcam     = false
    restreamer_whip      = false
    restreamer_srtingest = false
  }
}
