## Cluster Red5 Pro server deployment (cluster)

# Stream Manager 2.0 with Red5 Pro (SM2.0) Autoscaling Node Groups in GCP

This example Terraform module automates the infrastructure provisioning of Autoscale Stream Managers 2.0 with Red5 Pro (SM2.0) Autoscaling node groups (origins, edges, transcoders, relays) in GCP.

## Terraform Deployed Resources (cluster)

- VPC
- Public Subnet
- Cloud Router 
- Firewall Rules
  - Stream Manager 2.0
  - Kafka
  - Red5 Pro (SM2.0) Autoscaling Nodes
- SSH key pair (use existing or create a new one)
- Standalone Kafka instance
- Autoscaling configuration for Nodegroup instances
- HTTP(S) Load Balancer for Stream Manager 2.0 instances
- SSL Certificate for HTTP(S) Load Balancer:
  - `none`: Load Balancer without HTTPS and SSL certificate (HTTP on port `80`)
  - `letsencrypt`: Stream Manager 2.0 with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `80`, HTTPS on port `443`
  - `imported`: Load Balancer with HTTPS using an imported SSL certificate (HTTP on port `80`, HTTPS on port `443`)
- Red5 Pro (SM2.0) Node instance image (origins, edges, transcoders, relays)
- Red5 Pro (SM2.0) Autoscaling Node group (origins, edges, transcoders, relays)

## Example main.tf (autoscale)

```yaml
provider "google" {
  project = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro" {
  source            = "../../"
  google_region     = "us-west2"                 # Google region where resources will create eg: us-west2
  google_project_id = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version        = "22.04"                                 # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                  = "cluster"                               # Deployment type: standalone, cluster, autoscale
  name                  = "red5pro-cluster"                       # Name to be used on all the resources as identifier
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # SSH key configuration
  ssh_key_use_existing              = false                                               # Use existing SSH key pair or create a new one. true = use existing, false = create new SSH key pair
  ssh_key_public_key_path_existing  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_key.pub" # SSH public key path existing in local machine
  ssh_key_private_key_path_existing = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_key.pem" # SSH private key path existing in local machine

  # VPC configuration
  vpc_use_existing  = false              # true - use existing VPC, false - create new VPC in Google Cloud
  vpc_name_existing = "example-vpc-name" # VPC ID for existing VPC

  # Firewall configuration
  firewall_ssh_allowed_ip_ranges                    = ["0.0.0.0/0"]                      # List of IP address ranges to provide SSH connection with Red5 Pro instances. Kindly provide your public IP to make SSH connection while running this terraform module
  firewall_stream_manager_network_tags_use_existing = false                              # true - use existing firewall network tags, false - create new firewall network tags
  firewall_stream_manager_network_tags_existing     = ["example-tag-1", "example-tag-2"] # Existing network tags name for firewall configuration
  firewall_kafka_network_tags_use_existing          = false                              # true - use existing firewall network tags, false - create new firewall network tags
  firewall_kafka_network_tags_existing              = ["example-tag-1", "example-tag-2"] # Existing network tags name for firewall configuration
  firewall_nodes_network_tags_use_existing          = false                              # true - use existing firewall network tags, false - create new firewall network tags
  firewall_nodes_network_tags_existing              = ["example-tag-1", "example-tag-2"] # Existing network tags name for firewall configuration

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Kafka Service configuration
  kafka_standalone_instance_create = false           # true - Create a dedicate kafka service instance, false - install kafka service locally on the stream manager
  kafka_standalone_instance_type   = "n2-standard-2" # Kafka service Instance type
  kafka_standalone_disk_type       = "pd-ssd"        # Boot disk type for Kafka server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  kafka_standalone_disk_size       = 24              # Kafka server boot size in GB

  # Stream Manager configuration
  stream_manager_auth_user     = "example_user"     # Stream Manager 2.0 authentication user name
  stream_manager_auth_password = "example_password" # Stream Manager 2.0 authentication password
  stream_manager_proxy_user    = "example_proxy_user"       # Stream Manager 2.0 proxy user name
  stream_manager_proxy_password   = "example_proxy_password"   # Stream Manager 2.0 proxy password
  stream_manager_spatial_user     = "example_spatial_user"     # Stream Manager 2.0 spatial user name
  stream_manager_spatial_password = "example_spatial_password" # Stream Manager 2.0 spatial password
  stream_manager_version          = "latest"                   # Stream Manager 2.0 docker images version (latest, 14.1.0, 14.1.1, etc.) - https://hub.docker.com/r/red5pro/as-admin/tags
  stream_manager_instance_type = "n2-standard-2"    # Instance type for Red5 Pro stream manager server
  stream_manager_disk_type     = "pd-ssd"           # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  stream_manager_disk_size     = 24                 # Stream Manager server boot size in GB

  stream_manager_reserved_ip_use_existing  = false                 # True - Use already created reserved IP address for stream manager, False - Create a new reserved IP for stream manager
  stream_manager_reserved_ip_name_existing = "example-reserved-ip" # Reserved IP name for existing reserved IP address

  # Stream Manager 2.0 HTTPS (SSL) certificate configuration
  https_ssl_certificate = "none" # none - do not use HTTPS/SSL certificate, letsencrypt - create new Let's Encrypt HTTPS/SSL certificate, imported - use existing HTTPS/SSL certificate

  # # Example of Let's Encrypt HTTPS/SSL certificate configuration - please uncomment and provide your domain name and email
  # https_ssl_certificate                    = "letsencrypt"
  # https_ssl_certificate_domain_name        = "red5pro.example.com"
  # https_ssl_certificate_email              = "email@example.com"

  # # Example of imported HTTPS/SSL certificate configuration - please uncomment and provide your domain name, certificate and key paths
  # https_ssl_certificate                    = "imported"
  # https_ssl_certificate_domain_name        = "red5pro.example.com"
  # https_ssl_certificate_cert_path          = "/PATH/TO/SSL/CERT/fullchain.pem"
  # https_ssl_certificate_key_path           = "/PATH/TO/SSL/KEY/privkey.pem"

  # Red5 Pro cluster node image configuration
  node_image_create        = true            # Default: true for Autoscaling and Cluster, true - create new node image, false - not create new node image
  node_image_instance_type = "n2-standard-2" # Instance type for the Red5 Pro Node server
  node_image_disk_type     = "pd-ssd"        # Boot disk type for Node server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  node_image_disk_size     = 10              # Boot disk size for Node server

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

  # Red5 Pro autoscaling Node group
  node_group_create                    = true            # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_origins_min               = 1               # Number of minimum Origins
  node_group_origins_max               = 10              # Number of maximum Origins
  node_group_origins_instance_type     = "n2-standard-2" # Origins google instance type
  node_group_origins_disk_size         = 16              # Disk size for Origins
  node_group_origins_connection_limit  = 20              # Maximum number of publishers to the origin server
  node_group_edges_min                 = 1               # Number of minimum Edges
  node_group_edges_max                 = 20              # Number of maximum Edges
  node_group_edges_instance_type       = "n2-standard-2" # Edges google instance type
  node_group_edges_disk_size           = 16              # Disk size for Edges
  node_group_edges_connection_limit    = 200             # Maximum number of subscribers to the edge server
  node_group_transcoders_min           = 0               # Number of minimum Transcoders
  node_group_transcoders_max           = 10              # Number of maximum Transcoders
  node_group_transcoders_instance_type = "n2-standard-2" # Transcoders google instance type
  node_group_transcoders_disk_size     = 16              # Disk size for Transcoders
  node_group_transcoders_connection_limit = 20           # Maximum number of publishers to the transcoder server
  node_group_relays_min                = 0               # Number of minimum Relays
  node_group_relays_max                = 20              # Number of maximum Relays
  node_group_relays_instance_type      = "n2-standard-2" # Relays google instance type
  node_group_relays_disk_size          = 16              # Disk size for Relays
}

```