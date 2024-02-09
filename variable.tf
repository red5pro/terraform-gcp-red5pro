# Google Cloud Account configuration
variable "create_new_google_project" {
  description = "Create a new google project for creating Red5 Pro resources"
  type        = bool
  default     = false
}

variable "new_google_project_name" {
  description = "New google project name to be created"
  type        = string
  default     = ""
}

variable "google_cloud_organization_id" {
  description = "Organization ID of the Google cloud in which the Project will be created"
  type        = string
  default     = "0"
}

variable "existing_google_project_id" {
  description = "Use the existing google project to create resources of Red5 Pro"
  type        = string
  default     = ""
}

variable "google_region" {
  description = "Google Cloud region"
  type        = string
  default     = ""
}

variable "name" {
  description     = "Name to be used on all the resources as identifier"
  type            = string
  default         = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "The name value must be a valid! Example: example-name"
  }
}

variable "path_to_red5pro_build" {
  description     = "Path to the Red5 Pro build zip file, absolute path or relative path. https://account.red5pro.com/downloads. Example: /home/ubuntu/red5pro-server-0.0.0.b0-release.zip"
  type            = string
  default         = ""
  validation {
    condition     = fileexists(var.path_to_red5pro_build) == true
    error_message = "The path_to_red5pro_build value must be a valid! Example: /home/ubuntu/red5pro-server-0.0.0.b0-release.zip"
  }
}

variable "type" {
  description     = "Type of deployment: single, cluster, autoscaling"
  type            = string
  default         = "single"
  validation {
    condition     = var.type == "single" || var.type == "cluster" || var.type == "autoscaling"
    error_message = "The type value must be a valid! Example: single, cluster, autoscaling"
  }
}

# SSH keys Configuration
variable "create_new_ssh_keys" {
  description     = "Cretae a new SSH key pair which will be used for creating the virtual machines"
  type            = bool
  default         = true
}

variable "new_ssh_key_name" {
  description     = "SSH keys name to create ssh-key pair"
  type            = string
  default         = ""
}

variable "existing_public_ssh_key_path" {
  description     = "Already created public SSH key path"
  type            = string
  default         = ""
}

variable "existing_private_ssh_key_path" {
  description     = "Already created private SSH key path"
  type            = string
  default         = ""
}

# VPC configuration
variable "vpc_create" {
  description     = "Create a new VPC or use an existing one. true = create new, false = use existing"
  type            = bool
  default         = true
}
variable "existing_vpc_network_name" {
  description = "Name of the existing VPC network if `vpc_create` = false"
  type        = string
  default     = ""
}

# Ubuntu version Configuration
variable "ubuntu_version" {
  description     = "Ubuntu version used for instances. Available: 18.04, 20.04 and 22.04"
  type            = string
  default         = "22.04"
  validation {
    condition     = var.ubuntu_version == "18.04" || var.ubuntu_version == "20.04" || var.ubuntu_version == "22.04" 
    error_message = "Please specify the correct ubuntu version, it can either be 18.04, 20.04 or 22.04"
  }
}

variable "ubuntu_images_gcp" {
  description = "AWS images for different ubuntu versions"
  type        = map(string)
  default = {
    18.04     = "ubuntu-os-cloud/ubuntu-1804-lts"
    20.04     = "ubuntu-os-cloud/ubuntu-2004-lts"
    22.04     = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

# Red5 Single Server Configuration
variable "red5_single_firewall_ports" {
  description = "The required port open for the Red5 Single server in Google cloud firewall"
  type        = list(string)
  default     = ["22", "5080", "443", "80"]
}

variable "single_server_instance_type" {
  description = "Instance type for the single server"
  type        = string
  default     = ""
}
variable "single_server_boot_disk_type" {
  description = "Boot disk type for Single server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

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

variable "red5pro_inspector_enable" {
  description = "Red5 Pro Single server Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}

variable "red5pro_restreamer_enable" {
  description = "Red5 Pro Single server Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}

variable "red5pro_socialpusher_enable" {
  description = "Red5 Pro Single server SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}

variable "red5pro_suppressor_enable" {
  description = "Red5 Pro Single server Suppressor enable"
  type        = bool
  default     = false
}

variable "red5pro_hls_enable" {
  description = "Red5 Pro Single server HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}

variable "red5pro_round_trip_auth_enable" {
  description = "Round trip authentication on the red5pro server enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}

variable "red5pro_round_trip_auth_host" {
  description = "Round trip authentication server host"
  type        = string
  default     = ""
}

variable "red5pro_round_trip_auth_port" {
  description = "Round trip authentication server port"
  type        = number
  default     = 3000
}

variable "red5pro_round_trip_auth_protocol" {
  description = "Round trip authentication server protocol"
  type        = string
  default     = "http"
}

variable "red5pro_round_trip_auth_endpoint_validate" {
  description = "Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}

variable "red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Google Cloud Video On Demand via Cloud Storage configuration
variable "red5pro_cloudstorage_enable" {
  description = "Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/google-cloud-platform-storage/)"
  type        = bool
  default     = false
}

variable "red5pro_google_storage_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage access key "
  type        = string
  default     = ""
}

variable "red5pro_google_storage_secret_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage secret access key"
  type        = string
  default     = ""
}

variable "red5pro_google_storage_bucket_name" {
  description = "Red5 Pro server cloud storage - Google Cloud storage bucket name"
  type        = string
  default     = ""
}

variable "red5pro_cloudstorage_postprocessor_enable" {
  description = "Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/)"
  type        = bool
  default     = false
}

# HTTPS/SSL variables for single/cluster
variable "https_letsencrypt_enable" {
  description = "Enable HTTPS and get SSL certificate using Let's Encrypt automaticaly (single/cluster/autoscale) (https://www.red5pro.com/docs/installation/ssl/overview/)"
  type        = bool
  default     = false
}

variable "https_letsencrypt_certificate_domain_name" {
  description = "Domain name for Let's Encrypt ssl certificate (single/cluster/autoscale)"
  type        = string
  default     = ""
}

variable "https_letsencrypt_certificate_email" {
  description = "Email for Let's Encrypt ssl certificate (single/cluster/autoscale)"
  type        = string
  default     = ""
}

variable "https_letsencrypt_certificate_password" {
  description = "Password for Let's Encrypt ssl certificate (single/cluster/autoscale)"
  type        = string
  default     = ""
}

# Database Configuration
variable "mysql_database_create" {
  description     = "Create a new MySQL Database"
  type            = bool
  default         = false
}
variable "mysql_username" {
  description     = "MySQL user name if mysql_database_create = false"
  type            = string
  default         = ""
}
variable "mysql_instance_type" {
  description     = "MySQL Instance type"
  type            = string
  default         = ""
}
variable "mysql_port" {
  description     = "MySQL port to be used if mysql_database_create = false "
  type            = number
  default         = 3306
}
variable "mysql_password" {
  description     = "MySQL database password"
  type            = string
  default         = ""
  sensitive       = true
}

# Stream Manager Configuration
variable "red5_stream_manager_firewall_tcp_ports" {
  description = "The required port open for the Red5 Stream manager server in Google cloud firewall"
  type        = list(string)
  default     = ["22", "5080", "443", "80", "1935", "8554"]
}

variable "red5_stream_manager_firewall_udp_ports" {
  description = "The required port open for the Red5 Stream manager server in Google cloud firewall"
  type        = list(string)
  default     = ["40000-65535"]
}

variable "stream_manager_server_instance_type" {
  description = "Instance type for the Stream Manager server"
  type        = string
  default     = ""
}

variable "stream_manager_api_key" {
  description = "API Key for Red5Pro Stream Manager"
  type        = string
  default     = ""
}

variable "stream_manager_server_boot_disk_type" {
  description = "Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

variable "red5pro_cluster_key" {
  description = "Red5Pro Cluster Key"
  type        = string
  default     = ""
}

variable "path_to_google_cloud_controller" {
  description = "Path to the google cloud controller file, absolute path or relative path. https://account.red5pro.com/downloads. Example: /home/ubuntu/google-cloud-controller-0.0.0.jar"
  type        = string
  default     = ""
}

variable "existing_sm_reserved_ip_name" {
  description = "Already created Reserved IP address for stream manager"
  type        = string
  default     = ""
}

variable "create_new_reserved_ip_for_stream_manager" {
  description = "Create a new reserved IP for stream manager"
  type        = bool
  default     = true
}

# Load Balancer configuration
variable "count_of_stream_managers" {
  description = "Amount of Stream Managers to deploy in autoscale setup"
  type        = number
  default     = 1
}

variable "create_new_lb_ssl_cert" {
  description = "True - Create a new SSL certificate for the Load Balancer, False - Use existing SSL certificate for Load Balancer "
  type        = bool
  default     = true
}

variable "new_ssl_private_key_path" {
  description = "Path to the new SSL certificate private key file"
  type        = string
  default     = ""
}

variable "new_ssl_certificate_key_path" {
  description = "Path to the new SSL certificate key file"
  type        = string
  default     = ""
}

variable "existing_ssl_certificate_name" {
  description = "Existing SSL certificate name which is already created in the Google Cloud. If creating a new project in GCP, kindly create a new SSL certificate"
  type        = string
  default     = ""
}

# Red5 Pro Node Configuration
variable "red5_node_firewall_tcp_ports" {
  description = "The required port open for the Red5 node server in Google cloud firewall"
  type        = list(string)
  default     = ["22", "5080", "80", "1935", "8554"]
}

variable "red5_node_firewall_udp_ports" {
  description = "The required port open for the Red5 node server in Google cloud firewall"
  type        = list(string)
  default     = ["40000-65535", "8000-8001"]
}

# Red5 Pro Origin Configuration
variable "origin_image_create" {
  description = "Create new Origin node image true/false. (Default:true) (https://www.red5pro.com/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "origin_server_instance_type" {
  description = "Origin node instance type"
  type        = string
  default     = ""
}
variable "origin_server_boot_disk_type" {
  description = "Boot disk type for Origin server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

variable "origin_image_red5pro_inspector_enable" {
  description = "Origin node image - Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_restreamer_enable" {
  description = "Origin node image - Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_socialpusher_enable" {
  description = "Origin node image - SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_suppressor_enable" {
  description = "Origin node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_hls_enable" {
  description = "Origin node image - HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_round_trip_auth_enable" {
  description = "Origin node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_round_trip_auth_host" {
  description = "Origin node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "origin_image_red5pro_round_trip_auth_port" {
  description = "Origin node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "origin_image_red5pro_round_trip_auth_protocol" {
  description = "Origin node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "origin_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Origin node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "origin_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Origin node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}
variable "origin_red5pro_cloudstorage_enable" {
  description = "Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/azure-cloudstorage/)"
  type        = bool
  default     = false
}
variable "origin_red5pro_google_storage_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage access key "
  type        = string
  default     = ""
}

variable "origin_red5pro_google_storage_secret_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage secret access key"
  type        = string
  default     = ""
}

variable "origin_red5pro_google_storage_bucket_name" {
  description = "Red5 Pro server cloud storage - Google Cloud storage bucket name"
  type        = string
  default     = ""
}
variable "origin_red5pro_cloudstorage_postprocessor_enable" {
  description = "Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/)"
  type        = bool
  default     = false
}

# Red5 Pro Edge Configuration
variable "edge_image_create" {
  description = "Create new edge node image true/false. (Default:true) (https://www.red5pro.com/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "edge_server_instance_type" {
  description = "Edge node instance type"
  type        = string
  default     = ""
}
variable "edge_server_boot_disk_type" {
  description = "Boot disk type for Edge server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

variable "edge_image_red5pro_inspector_enable" {
  description = "Edge node image - Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_restreamer_enable" {
  description = "Edge node image - Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_socialpusher_enable" {
  description = "Edge node image - SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_suppressor_enable" {
  description = "Edge node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_hls_enable" {
  description = "Edge node image - HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_round_trip_auth_enable" {
  description = "Edge node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_round_trip_auth_host" {
  description = "Edge node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "edge_image_red5pro_round_trip_auth_port" {
  description = "Edge node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "edge_image_red5pro_round_trip_auth_protocol" {
  description = "Edge node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "edge_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Edge node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "edge_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Edge node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Transcoder Configuration
variable "transcoder_image_create" {
  description = "Create new Transcoder node image true/false. (Default:true) (https://www.red5pro.com/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "transcoder_server_instance_type" {
  description = "Transcoder node instance type"
  type        = string
  default     = ""
}
variable "transcoder_server_boot_disk_type" {
  description = "Boot disk type for Transcoder server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

variable "transcoder_image_red5pro_inspector_enable" {
  description = "Transcoder node image - Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_restreamer_enable" {
  description = "Transcoder node image - Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_socialpusher_enable" {
  description = "Transcoder node image - SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_suppressor_enable" {
  description = "Transcoder node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_hls_enable" {
  description = "Transcoder node image - HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_round_trip_auth_enable" {
  description = "Transcoder node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_round_trip_auth_host" {
  description = "Transcoder node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "transcoder_image_red5pro_round_trip_auth_port" {
  description = "Transcoder node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "transcoder_image_red5pro_round_trip_auth_protocol" {
  description = "Transcoder node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "transcoder_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Transcoder node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "transcoder_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Transcoder node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}
variable "transcoder_red5pro_cloudstorage_enable" {
  description = "Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/azure-cloudstorage/)"
  type        = bool
  default     = false
}
variable "transcoder_red5pro_google_storage_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage access key "
  type        = string
  default     = ""
}

variable "transcoder_red5pro_google_storage_secret_access_key" {
  description = "Red5 Pro server cloud storage - Google Cloud storage secret access key"
  type        = string
  default     = ""
}

variable "transcoder_red5pro_google_storage_bucket_name" {
  description = "Red5 Pro server cloud storage - Google Cloud storage bucket name"
  type        = string
  default     = ""
}
variable "transcoder_red5pro_cloudstorage_postprocessor_enable" {
  description = "Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/)"
  type        = bool
  default     = false
}

# Red5 Pro Relay Configuration
variable "relay_image_create" {
  description = "Create new Relay node image true/false. (Default:true) (https://www.red5pro.com/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "relay_server_instance_type" {
  description = "Relay node instance type"
  type        = string
  default     = ""
}
variable "relay_server_boot_disk_type" {
  description = "Boot disk type for Relay server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`"
  type        = string
  default     = ""
}

variable "relay_image_red5pro_inspector_enable" {
  description = "Relay node image - Inspector enable/disable (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_restreamer_enable" {
  description = "Relay node image - Restreamer enable/disable (https://www.red5pro.com/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_socialpusher_enable" {
  description = "Relay node image - SocialPusher enable/disable (https://www.red5pro.com/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_suppressor_enable" {
  description = "Relay node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_hls_enable" {
  description = "Relay node image - HLS enable/disable (https://www.red5pro.com/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_round_trip_auth_enable" {
  description = "Relay node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5pro.com/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_round_trip_auth_host" {
  description = "Relay node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "relay_image_red5pro_round_trip_auth_port" {
  description = "Relay node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "relay_image_red5pro_round_trip_auth_protocol" {
  description = "Relay node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "relay_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Relay node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "relay_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Relay node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro autoscaling Node group - (Optional) 
variable "node_group_create" {
  description = "Create new node group. Linux or Mac OS only."
  type        = bool
  default     = false
}
variable "node_group_name" {
  description = "Node group name"
  type        = string
  default     = ""
}
variable "node_group_origins" {
  description = "Number of Origins"
  type        = number
  default     = 1
}
variable "node_group_origins_instance_type" {
  description = "Instance type for Origins"
  type        = string
  default     = ""
}
variable "node_group_origins_capacity" {
  description = "Connections capacity for Origins"
  type        = number
  default     = 30
}
variable "node_group_edges" {
  description = "Number of Edges"
  type        = number
  default     = 1
}
variable "node_group_edges_instance_type" {
  description = "Instance type for Edges"
  type        = string
  default     = ""
}
variable "node_group_edges_capacity" {
  description = "Connections capacity for Edges"
  type        = number
  default     = 300
}
variable "node_group_transcoders" {
  description = "Number of Transcoders"
  type        = number
  default     = 1
}
variable "node_group_transcoders_instance_type" {
  description = "Instance type for Transcoders"
  type        = string
  default     = ""
}
variable "node_group_transcoders_capacity" {
  description = "Connections capacity for Transcoders"
  type        = number
  default     = 30
}
variable "node_group_relays" {
  description = "Number of Relays"
  type        = number
  default     = 1
}
variable "node_group_relays_instance_type" {
  description = "Instance type for Relays"
  type        = string
  default     = ""
}
variable "node_group_relays_capacity" {
  description = "Connections capacity for Relays"
  type        = number
  default     = 30
}