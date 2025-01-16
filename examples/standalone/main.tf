###################################################
# Example for Standalone Red5 Pro server deployment 
###################################################
provider "google" {
  project = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro" {
  source            = "../../"
  google_region     = "us-west2"                 # Google region where resources will create eg: us-west2
  google_project_id = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version        = "22.04"                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                  = "standalone"                          # Deployment type: standalone, cluster, autoscale
  name                  = "red5pro-standalone"                  # Name to be used on all the resources as identifier
  path_to_red5pro_build = "./red5pro-server-0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # SSH key configuration
  ssh_key_use_existing              = false                                               # Use existing SSH key pair or create a new one. true = use existing, false = create new SSH key pair
  ssh_key_public_key_path_existing  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_key.pub" # SSH public key path existing in local machine
  ssh_key_private_key_path_existing = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_key.pem" # SSH private key path existing in local machine

  # VPC configuration
  vpc_use_existing  = false              # true - use existing VPC, false - create new VPC in Google Cloud
  vpc_name_existing = "example-vpc-name" # VPC ID for existing VPC

  # Firewall configuration
  firewall_ssh_allowed_ip_ranges                = ["0.0.0.0/0"]                      # List of IP address ranges to provide SSH connection with Red5 Pro instances. Kindly provide your public IP to make SSH connection while running this terraform module
  firewall_standalone_network_tags_use_existing = false                              # true - use existing firewall network tags, false - create new firewall network tags
  firewall_standalone_network_tags_existing     = ["example-tag-1", "example-tag-2"] # Existing network tags name for firewall configuration

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Standalone Red5 Pro server Instance configuration
  standalone_instance_type = "n2-standard-2" # Instance type for Red5 Pro server
  standalone_disk_type     = "pd-ssd"        # Boot disk type for Standalone server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  standalone_disk_size     = 16              # Standalone server boot disk size in GB

  # Red5Pro server configuration
  standalone_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  standalone_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  standalone_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  standalone_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  standalone_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  standalone_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  standalone_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  standalone_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  standalone_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  standalone_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  standalone_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate
  standalone_red5pro_cloudstorage_enable                 = false                         # Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/google-cloud-platform-storage/)
  standalone_red5pro_google_storage_access_key           = ""                            # Red5 Pro server cloud storage - Gogle storage account access key
  standalone_red5pro_google_storage_secret_access_key    = ""                            # Red5 Pro server cloud storage - Gogle storage account secret access key
  standalone_red5pro_google_storage_bucket_name          = ""                            # Red5 Pro server cloud storage - Gogle storage bucket name
  standalone_red5pro_cloudstorage_postprocessor_enable   = false                         # Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/) 

  # Standalone Red5 Pro server HTTPS (SSL) certificate configuration
  https_ssl_certificate = "none" # none - do not use HTTPS/SSL certificate, letsencrypt - create new Let's Encrypt HTTPS/SSL certificate, imported - use existing HTTPS/SSL certificate

  # # Example of Let's Encrypt HTTPS/SSL certificate configuration - please uncomment and provide your domain name and email
  # https_ssl_certificate                       = "letsencrypt"
  # https_ssl_certificate_domain_name           = "red5pro.example.com"
  # https_ssl_certificate_email                 = "email@example.com"

  # # Example of imported HTTPS/SSL certificate configuration - please uncomment and provide your domain name, certificate and key paths
  # https_ssl_certificate                       = "imported"
  # https_ssl_certificate_domain_name           = "red5pro.example.com"
  # https_ssl_certificate_cert_path             = "/PATH/TO/SSL/CERT/fullchain.pem"
  # https_ssl_certificate_key_path              = "/PATH/TO/SSL/KEY/privkey.pem"
}

