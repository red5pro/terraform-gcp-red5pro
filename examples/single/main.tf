#################################################
# Example for single Red5 Pro server deployment 
#################################################
provider "google" {
  project                   = "example-gcp-project-name"                                     # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_single" {
  source                    = "../../"
  google_region             = "us-west2"                                                     # Google region where resources will create eg: us-west2
  google_project_id         = "example-gcp-project-name"                                     # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version            = "22.04"                                                        # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                      = "single"                                                       # Deployment type: single, cluster, autoscaling
  name                      = "red5pro-single"                                               # Name to be used on all the resources as identifier
  path_to_red5pro_build     = "./red5pro-server-0.0.b0-release.zip"                          # Absolute path or relative path to Red5 Pro server ZIP file

  # SSH key configuration
  create_new_ssh_keys              = true                                                    # true - create new SSH key, false - use existing SSH key
  new_ssh_key_name                 = "example-ssh-key"                                          # if `create_new_ssh_keys` = true, Name for new SSH key
  existing_public_ssh_key_path     = "./example-ssh-key.pub"                                  # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-ssh-key.pem"                                 # if `create_new_ssh_keys` = false, Path to existing SSH private key

  # VPC configuration
  vpc_create                       = true                                                    # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name        = "example-vpc-name"                                      # if `vpc_create` = false, Existing VPC name used for the network configuration in Google Cloud

  # Single Red5 Pro server HTTPS/SSL certificate configuration
  https_letsencrypt_enable                   = false                                         # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name  = "red5pro.example.com"                         # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email        = "email@example.com"                           # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password     = "examplepass"                                 # Password for Let's Encrypt SSL certificate
  
  # Single Red5 Pro server Instance configuration
  single_server_instance_type                   = "n2-standard-2"                            # Instance type for Red5 Pro server
  single_server_boot_disk_type                  = "pd-ssd"                                   # Boot disk type for Single server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`

  # Red5Pro server configuration
  red5pro_license_key                           = "1111-2222-3333-4444"                      # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable                            = true                                       # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                               = "examplekey"                               # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)
  red5pro_inspector_enable                      = false                                      # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  red5pro_restreamer_enable                     = false                                      # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  red5pro_socialpusher_enable                   = false                                      # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  red5pro_suppressor_enable                     = false                                      # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  red5pro_hls_enable                            = false                                      # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  red5pro_round_trip_auth_enable                = false                                      # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  red5pro_round_trip_auth_host                  = "round-trip-auth.example.com"              # Round trip authentication server host
  red5pro_round_trip_auth_port                  = 3000                                       # Round trip authentication server port
  red5pro_round_trip_auth_protocol              = "http"                                     # Round trip authentication server protocol
  red5pro_round_trip_auth_endpoint_validate     = "/validateCredentials"                     # Round trip authentication server endpoint for validate
  red5pro_round_trip_auth_endpoint_invalidate   = "/invalidateCredentials"                   # Round trip authentication server endpoint for invalidate
  red5pro_cloudstorage_enable                   = false                                      # Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/google-cloud-platform-storage/)
  red5pro_google_storage_access_key             = ""                                         # Red5 Pro server cloud storage - Gogle storage account access key
  red5pro_google_storage_secret_access_key      = ""                                         # Red5 Pro server cloud storage - Gogle storage account secret access key
  red5pro_google_storage_bucket_name            = ""                                         # Red5 Pro server cloud storage - Gogle storage bucket name
  red5pro_cloudstorage_postprocessor_enable     = false                                      # Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/) 
}

output "module_output" {
  sensitive = true
  value = module.red5pro_single
}