####################################################
# Example for Autoscaling Red5 Pro server deployment
####################################################
provider "google" {
  project                    = "example-gcp-project-name"                                  # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_autoscaling" {
  source                           = "../../"
  google_region                    = "us-west2"                                            # Google region where resources will create eg: us-west2
  google_project_id                = "example-gcp-project-name"                            # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version                   = "22.04"                                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                             = "autoscaling"                                         # Deployment type: single, cluster, autoscaling
  name                             = "red5pro-autoscaling"                                 # Name to be used on all the resources as identifier
  path_to_red5pro_build            = "./red5pro-server-0.0.0.b0-release.zip"               # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_terraform_cloud_controller  = "./terraform-cloud-controller-0.0.0.jar"           # Absolute path or relative path to terraform cloud controller jar file
  path_to_terraform_service_build     = "./terraform-service-0.0.0.zip"                    # Absolute path or relative path to terraform service ZIP file

  # SSH key configuration
  create_new_ssh_keys              = true                                                  # true - create new SSH key, false - use existing SSH key
  new_ssh_key_name                 = "example-ssh-key"                                     # if `create_new_ssh_keys` = true, Name for new SSH key
  existing_public_ssh_key_path     = "./example-ssh-key.pub"                               # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-ssh-key.pem"                               # if `create_new_ssh_keys` = false, Path to existing SSH private key
  
  # VPC configuration
  vpc_create                       = true                                                  # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name        = "example-vpc-name"                                    # if `vpc_create` = false, Existing VPC name used for the network configuration

  # Database Configuration
  mysql_instance_type              = "db-n1-standard-2"                                    # New database instance type (https://cloud.google.com/sdk/gcloud/reference/sql/tiers/list)
  mysql_username                   = "example-user"                                        # Username for locally install databse and dedicated database in google
  mysql_password                   = "ExamplePassword123"                                  # Password for locally install databse and dedicated database in google
  mysql_port                       = 3306                                                  # Port for locally install databse and dedicated database in google

  # Red5 Pro general configuration
  red5pro_license_key              = "1111-2222-3333-4444"                                 # Red5 Pro license key (https://account.red5.net/login)
  red5pro_cluster_key              = "examplekey"                                          # Red5 Pro cluster key
  red5pro_api_enable               = true                                                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                  = "examplekey"                                          # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)
  
  # Red5 Pro Server Instance configuration
  stream_manager_server_instance_type  = "n2-standard-2"                                   # Instance type for Red5 Pro stream manager server
  stream_manager_api_key               = "examplekey"                                      # Stream Manager api key
  stream_manager_server_boot_disk_type = "pd-ssd"                                          # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  stream_manager_server_disk_size      = 10                                                # Stream Manager server boot size in GB
  stream_manager_network_tag           = "example-sm-instance"                             # Specify the Network Tag for Stream Manager to be used by the Virtual Network firewall

  # Terraform Service configuration
  terraform_service_api_key         = "examplekey"                                         # Terraform service api key
  terraform_service_parallelism     = "20"                                                 # Terraform service parallelism
  terraform_service_network_tag     = "example-terraform-service-instance"                 # Specify the Network Tag for Terraform Service instance to be used by the Virtual Network firewall
  terraform_service_boot_disk_type  = "pd-ssd"                                             # Boot disk type for Terraform server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  terraform_service_instance_type   = "n2-standard-2"                                      # Terraform service Instance type
  gcp_node_boot_disk_type           = "pd-ssd"                                             # Boot disk type for Nodes in Terraform Service. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  gcp_node_network_tag              = "example-node-instance"                              # Specify new/existing Node Network tag which will be used by Terraform service while creating Node and it will be utilized by Firewall in GCP. Default value is null

  # Load Balancer Configuration
  create_new_global_reserved_ip_for_lb = true                                              # True - Create a new reserved IP for Load Balancer, False - Use existing reserved IP for Load Balancer
  existing_global_lb_reserved_ip_name  = ""                                                # If `create_new_global_reserved_ip_for_lb` - False, Use the already created Load balancer IP address name
  lb_http_port_required                = "5080"                                            # The required HTTP port used by Load Balancer other than HTTPS, Default 5080
  count_of_stream_managers             = 1                                                 # Amount of Stream Managers to deploy in autoscale setup
  create_lb_with_ssl                   = true                                              # True- Create the Load Balancer with SSL, False - Create the Load Balancer without SSL
  create_new_lb_ssl_cert               = true                                              # if `create_lb_with_ssl` True - Create a new SSL certificate for the Load Balancer, False - Use existing SSL certificate for Load Balancer
  new_ssl_private_key_path             = "/path/to/privkey.pem"                            # if `create_lb_with_ssl` and `create_new_lb_ssl_cert` = true, Path to the new SSL certificate private key file
  new_ssl_certificate_key_path         = "/path/to/fullchain.pem"                          # if `create_lb_with_ssl` and `create_new_lb_ssl_cert` = true, Path to the new SSL certificate key file
  existing_ssl_certificate_name        = "example-certificate-name"                        # if `create_lb_with_ssl` - False, Create the Load balancer without any SSL But, if `create_new_lb_ssl_cert` = false and `create_lb_with_ssl` - True, Existing SSL certificate name which is already created in the Google Cloud. If creating a new project in GCP, kindly create a new SSL certificate

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
  origin_red5pro_cloudstorage_enable                       = false                         # Red5 Pro server cloud storage enable/disable (https://www.red5.net/docs/special/cloudstorage-plugin/google-cloud-platform-storage/)
  origin_red5pro_google_storage_access_key                 = ""                            # Red5 Pro server cloud storage - Google Cloud storage access key
  origin_red5pro_google_storage_secret_access_key          = ""                            # Red5 Pro server cloud storage - Google Cloud storage secret access key
  origin_red5pro_google_storage_bucket_name                = ""                            # Red5 Pro server cloud storage - Google Cloud storage bucket name
  origin_red5pro_cloudstorage_postprocessor_enable         = false                         # Red5 Pro server cloud storage - enable/disable Red5 Pro server postprocessor (https://www.red5.net/docs/special/cloudstorage-plugin/server-configuration/) 

  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create                     = true                                             # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_name                       = "example-node-group"                             # Node group name
  # Origin node configuration
  node_group_origins_min                = 1                                                # Number of minimum Origins
  node_group_origins_max                = 20                                               # Number of maximum Origins
  node_group_origins_instance_type      = "n2-standard-2"                                  # Origins google instance
  node_group_origins_capacity           = 20                                               # Connections capacity for Origins
  # Edge node configuration
  node_group_edges_min                  = 1                                                # Number of minimum Edges
  node_group_edges_max                  = 40                                               # Number of maximum Edges
  node_group_edges_instance_type        = "n2-standard-2"                                  # Edges google instance
  node_group_edges_capacity             = 200                                              # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders_min            = 0                                                # Number of minimum Transcoders
  node_group_transcoders_max            = 20                                               # Number of maximum Transcoders
  node_group_transcoders_instance_type  = "n2-standard-2"                                  # Transcoders google instance
  node_group_transcoders_capacity       = 20                                               # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays_min                 = 0                                                # Number of minimum Relays
  node_group_relays_max                 = 20                                               # Number of maximum Relays
  node_group_relays_instance_type       = "n2-standard-2"                                  # Relays google instance
  node_group_relays_capacity            = 20                                               # Connections capacity for Relays
}

output "module_output" {
  sensitive = true
  value = module.red5pro_autoscaling
}