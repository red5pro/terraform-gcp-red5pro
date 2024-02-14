#################################################
# Example for Cluster Red5 Pro server deployment
#################################################
module "red5pro_cluster" {
  source                     = "../../"
  google_region              = "asia-south1"                                               # Google region where resources will create eg: us-west2

  create_new_google_project          = false                                               # True - Create a new project in Gogle account, False - Use existing google project
  new_google_project_name            = ""                                                  # If create_new_google_project = true, Provide the new google project id
  existing_google_project_id         = ""                                                  # If create_new_google_project = false, provide the existing google projct id

  ubuntu_version            = "22.04"                                                      # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                      = "cluster"                                                    # Deployment type: single, cluster, autoscaling
  name                      = "red5pro-cluster"                                            # Name to be used on all the resources as identifier
  path_to_red5pro_build     = "./red5pro-server-0.0.0.b0-release.zip"                      # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_google_cloud_controller = "./google-cloud-controller-0.0.0.jar"                  # Absolute path or relative path to google cloud controller jar file
 
  # SSH key configuration
  create_new_ssh_keys              = true                                                  # true - create new SSH key, false - use existing SSH key
  new_ssh_key_name                 = "new_key_name"                                        # if `create_new_ssh_keys` = true, Name for new SSH key
  existing_public_ssh_key_path     = "./example-public.pub"                                # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-private.pem"                               # if `create_new_ssh_keys` = false, Path to existing SSH private key
  
  # VPC configuration
  vpc_create                       = true                                                  # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name        = ""                                                    # if `vpc_create` = false, Existing VPC name used for the network configuration

  # Database Configuration
  mysql_database_create     = false                                                        # true - create a new database false- Install locally
  mysql_instance_type       = ""                                                           # New database instance type
  mysql_username            = "example-user"                                               # Username for locally install databse and dedicated database in google
  mysql_password            = ""                                                           # Password for locally install databse and dedicated database in google
  mysql_port                = 3306                                                         # Port for locally install databse and dedicated database in google

  # Red5 Pro general configuration
  red5pro_license_key                           = "1111-2222-3333-4444"                    # Red5 Pro license key (https://account.red5.net/login)
  red5pro_cluster_key                           = ""                                       # Red5 Pro cluster key
  red5pro_api_enable                            = true                                     # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                               = ""                                       # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Red5 Pro server HTTPS/SSL certificate configuration
  https_letsencrypt_enable                   = false                                       # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name  = "red5pro.example.com"                       # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email        = "email@example.com"                         # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password     = "examplepass"                               # Password for Let's Encrypt SSL certificate
  
  # Red5 Pro server Instance configuration
  create_new_reserved_ip_for_stream_manager     = true                                     # True - Create a new reserved IP for stream manager, False - Use already created reserved IP address
  existing_sm_reserved_ip_name                  = ""                                       # If `create_new_reserved_ip_for_stream_manager` = false then specify the name of already create reserved IP for stream manager in the provided region.
  stream_manager_server_instance_type           = "n2-standard-2"                          # Instance type for Red5 Pro stream manager server
  stream_manager_api_key                        = ""                                       # Stream Manager api key
  stream_manager_server_boot_disk_type          = "pd-ssd"                                 # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`

  # Red5 Pro cluster Origin node image configuration
  origin_image_create                                      = true                          # Default: true for Autoscaling and Cluster, true - create new Origin node image, false - not create new Origin node image
  origin_server_instance_type                              = "n2-standard-2"               # Instance type for the Red5 Pro Origin server
  origin_server_boot_disk_type                             = "pd-ssd"                      # Boot disk type for Origin server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  origin_image_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  origin_image_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  origin_image_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  origin_image_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  origin_image_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  origin_image_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  origin_image_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  origin_image_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  origin_image_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  origin_image_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  origin_image_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate
  origin_red5pro_cloudstorage_enable                   = false                             # Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/azure-cloudstorage/)
  origin_red5pro_google_storage_access_key             = ""                                # Red5 Pro server cloud storage - Google Cloud storage access key
  origin_red5pro_google_storage_secret_access_key      = ""                                # Red5 Pro server cloud storage - Google Cloud storage secret access key
  origin_red5pro_google_storage_bucket_name            = ""                                # Red5 Pro server cloud storage - Google Cloud storage bucket name
  origin_red5pro_cloudstorage_postprocessor_enable     = false                             # Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/) 

  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create                   = true                                               # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_name                     = "example-node-group"                               # Node group name
  # Origin node configuration
  node_group_origins                  = 1                                                  # Number of Origins
  node_group_origins_instance_type     = "n2-standard-2"                                   # Origins google instance
  node_group_origins_capacity         = 30                                                 # Connections capacity for Origins
  # Edge node configuration
  node_group_edges                    = 1                                                  # Number of Edges
  node_group_edges_instance_type       = "n2-standard-2"                                   # Edges google instance
  node_group_edges_capacity           = 300                                                # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders              = 0                                                  # Number of Transcoders
  node_group_transcoders_instance_type = "n2-standard-2"                                   # Transcoders google instance
  node_group_transcoders_capacity     = 30                                                 # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays                   = 0                                                  # Number of Relays
  node_group_relays_instance_type      = "n2-standard-2"                                   # Relays google instance
  node_group_relays_capacity          = 30                                                 # Connections capacity for Relays

}

output "module_output" {
  sensitive = true
  value = module.red5pro_cluster
}