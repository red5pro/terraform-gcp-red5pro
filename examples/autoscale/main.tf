####################################################
# Example for Autoscale Red5 Pro server deployment
####################################################
provider "google" {
  project                    = "example-gcp-project-name"                                  # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_autoscale" {
  source                           = "../../"
  google_region                    = "us-west2"                                            # Google region where resources will create eg: us-west2
  google_project_id                = "example-gcp-project-name"                            # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version                   = "22.04"                                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                             = "autoscale"                                           # Deployment type: standalone, cluster, autoscale
  name                             = "red5pro-autoscale"                                   # Name to be used on all the resources as identifier
  path_to_red5pro_build            = "./red5pro-server-0.0.0.b0-release.zip"               # Absolute path or relative path to Red5 Pro server ZIP file

  # SSH key configuration
  create_new_ssh_keys              = true                                                  # true - create new SSH key, false - use existing SSH key
  existing_public_ssh_key_path     = "./example-ssh-key.pub"                               # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-ssh-key.pem"                               # if `create_new_ssh_keys` = false, Path to existing SSH private key
  
  # VPC configuration
  vpc_create                                        = true                                 # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name                         = "example-vpc-name"                   # if `vpc_create` = false, Existing VPC name used for the network configuration
  create_new_firewall_for_kafka_standalone          = true                                 # True - Create a new firewall for Kafka service in VPC, False - Use existing firewall of VPC using network tag
  create_new_firewall_for_stream_manager            = true                                 # True - Create a new firewall in VPC, False - Use existing firewall of VPC using network tag
  create_new_firewall_for_nodes                     = true                                 # True - Create a new firewall for Red5 Node in VPC, False - Use existing firewall of VPC using network tag
  new_or_existing_network_tag_for_kafka_standalone  = "example-kafka-service-instance"     # Specify the new or existing Network Tag for Kafka Service to be used by the Virtual Network firewall. If `vpc_create = true` specify new network tag, if `vpc_create = false` specify existing network tag for Kafka Service
  new_or_existing_network_tag_for_stream_manager    = "example-sm-instance"                # Specify the new or existing Network Tag for Stream Manager to be used by the Virtual Network firewall. If `vpc_create = true` specify new network tag, if `vpc_create = false` specify existing network tag for stream manager
  new_or_existing_network_tag_for_nodes             = "example-node-instance"              # Specify new/existing Node Network tag which will be used by as-terraform service while creating Node and it will be utilized by Firewall in GCP. If `vpc_create = true` specify new network tag for red5 node, if `vpc_create = false` specify existing network tag for red5 node

  # Red5 Pro general configuration
  red5pro_license_key                        = "1111-2222-3333-4444"                       # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable                         = true                                        # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                            = "examplekey"                                # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Kafka Service configuration
  kafka_standalone_boot_disk_type              = "pd-ssd"                                  # Boot disk type for Kafka server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  kafka_standalone_instance_type               = "n2-standard-2"                           # Kafka service Instance type
  kafka_standalone_disk_size                    = 50 
  
  # Red5 Pro server Instance configuration
  stream_manager_auth_user                   = "example_user"                              # Stream Manager 2.0 authentication user name
  stream_manager_auth_password               = "example_password"                          # Stream Manager 2.0 authentication password
  stream_manager_server_instance_type        = "n2-standard-2"                             # Instance type for Red5 Pro stream manager server
  stream_manager_server_boot_disk_type       = "pd-ssd"                                    # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  stream_manager_server_disk_size            = 50                                          # Stream Manager server boot size in GB
  create_new_reserved_ip_for_stream_manager  = true                                        # True - Create a new reserved IP for stream manager, False - Use already created reserved IP address
  existing_sm_reserved_ip_name               = "example-reserved-ip"                       # If `create_new_reserved_ip_for_stream_manager` = false then specify the name of already create reserved IP for stream manager in the provided region.

  # Load Balancer Configuration
  create_new_global_reserved_ip_for_lb = true                                              # True - Create a new reserved IP for Load Balancer, False - Use existing reserved IP for Load Balancer
  existing_global_lb_reserved_ip_name  = "existing-reserved-ip-name"                       # If `create_new_global_reserved_ip_for_lb` - False, Use the already created Load balancer IP address name
  count_of_stream_managers             = 1                                                 # Amount of Stream Managers to deploy in autoscale setup
  create_lb_with_ssl                   = true                                              # True- Create the Load Balancer with SSL, False - Create the Load Balancer without SSL
  create_new_lb_ssl_cert               = true                                              # if `create_lb_with_ssl` True - Create a new SSL certificate for the Load Balancer, False - Use existing SSL certificate for Load Balancer
  new_ssl_private_key_path             = "/path/to/privkey.pem"                            # if `create_lb_with_ssl` and `create_new_lb_ssl_cert` = true, Path to the new SSL certificate private key file
  new_ssl_certificate_key_path         = "/path/to/fullchain.pem"                          # if `create_lb_with_ssl` and `create_new_lb_ssl_cert` = true, Path to the new SSL certificate key file
  existing_ssl_certificate_name        = "example-certificate-name"                        # if `create_lb_with_ssl` - False, Create the Load balancer without any SSL But, if `create_new_lb_ssl_cert` = false and `create_lb_with_ssl` - True, Existing SSL certificate name which is already created in the Google Cloud. If creating a new project in GCP, kindly create a new SSL certificate
  
  # Red5 Pro cluster node image configuration
  node_image_create                          = true                                        # Default: true for Autoscaling and Cluster, true - create new node image, false - not create new node image
  node_server_instance_type                  = "n2-standard-2"                             # Instance type for the Red5 Pro Node server
  node_server_boot_disk_type                 = "pd-ssd"                                    # Boot disk type for Node server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  
  # Extra configuration for Red5 Pro autoscaling nodes
  # Webhooks configuration - (Optional) https://www.red5.net/docs/special/webhooks/overview/
  node_config_webhooks = {
    enable           = false,
    target_nodes     = ["origin", "edge", "transcoder"],
    webhook_endpoint = "https://test.webhook.app/api/v1/broadcast/webhook"
  }
  # Round trip authentication configuration - (Optional) https://www.red5.net/docs/special/authplugin/simple-auth/
  node_config_round_trip_auth = {
    enable                   = false,
    target_nodes             = ["origin", "edge", "transcoder"],
    auth_host                = "round-trip-auth.example.com",
    auth_port                = 443,
    auth_protocol            = "https://",
    auth_endpoint_validate   = "/validateCredentials",
    auth_endpoint_invalidate = "/invalidateCredentials"
  }
  # Restreamer configuration - (Optional) https://www.red5.net/docs/special/restreamer/overview/
  node_config_restreamer = {
    enable               = false,
    target_nodes         = ["origin", "transcoder"],
    restreamer_tsingest  = true,
    restreamer_ipcam     = true,
    restreamer_whip      = true,
    restreamer_srtingest = true
  }
  # Social Pusher configuration - (Optional) https://www.red5.net/docs/development/social-media-plugin/rest-api/
  node_config_social_pusher = {
    enable       = false,
    target_nodes = ["origin", "edge", "transcoder"],
  }


  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create                     = true                                             # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  # Origin node configuration
  node_group_origins_min                = 1                                                # Number of minimum Origins
  node_group_origins_max                = 20                                               # Number of maximum Origins
  node_group_origins_instance_type      = "n2-standard-2"                                  # Origins google instance type
  node_group_origins_volume_size        = 50                                               # Volume size for Origins
  # Edge node configuration
  node_group_edges_min                  = 1                                                # Number of minimum Edges
  node_group_edges_max                  = 40                                               # Number of maximum Edges
  node_group_edges_instance_type        = "n2-standard-2"                                  # Edges google instance type
  node_group_edges_volume_size          = 50                                               # Volume size for Edges
  # Transcoder node configuration
  node_group_transcoders_min            = 0                                                # Number of minimum Transcoders
  node_group_transcoders_max            = 20                                               # Number of maximum Transcoders
  node_group_transcoders_instance_type  = "n2-standard-2"                                  # Transcoders google instance type
  node_group_transcoders_volume_size    = 50                                               # Volume size for Transcoders
  # Relay node configuration
  node_group_relays_min                 = 0                                                # Number of minimum Relays
  node_group_relays_max                 = 20                                               # Number of maximum Relays
  node_group_relays_instance_type       = "n2-standard-2"                                  # Relays google instance type
  node_group_relays_volume_size         = 50                                               # Volume size for Relays
}

output "module_output" {
  sensitive = true
  value = module.red5pro_autoscale
}
