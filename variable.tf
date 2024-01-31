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