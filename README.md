# Google Cloud Red5 Pro Terraform module
[Red5 Pro](https://www.red5.net/) is a real-time video streaming server plaform known for its low-latency streaming capabilities, making it ideal for interactive applications like online gaming, streaming events and video conferencing etc.

This a reusable Terraform installer module for [Red5 Pro](https://www.red5.net/docs/installation/installation/googlecloudvminstall/) that provisions infrastucture over [Google Cloud(Gcloud)](https://console.cloud.google.com/).

## This module has 3 variants of Red5 Pro deployments

* **standalone** - Single instance with installed and configured Red5 Pro server
* **cluster** - Stream Manager cluster (Stream Manager instance + Autoscaling Node group with Origin, Edge, Transcoder, Relay instance)
* **autoscale** - Autoscale Stream Managers (Load Balancer + Autoscaling Stream Managers + Kafka Service + Autoscaling Node group with Origin, Edge, Transcoder, Relay instance)

---

## Preparation

* Install **terraform** https://developer.hashicorp.com/terraform/downloads
  * Open your web browser and visit the [Terraform download page](https://developer.hashicorp.com/terraform/downloads), ensuring you get version 1.0.0 or higher. 
  * Download the suitable version for your operating system, 
  * Extract the compressed file, and then copy the Terraform binary to a location within your system's path
    * Configure path on Linux/macOS 
      * Open a terminal and type the following:

        ```$ sudo mv /path/to/terraform /usr/local/bin```
    * Configure path on Windows OS
      * Click 'Start', search for 'Control Panel', and open it.
      * Navigate to System > Advanced System Settings > Environment Variables.
      * Under System variables, find 'PATH' and click 'Edit'.
      * Click 'New' and paste the directory location where you extracted the terraform.exe file.
      * Confirm changes by clicking 'OK' and close all open windows.
      * Open a new terminal and verify that Terraform has been successfully installed.

* Install **Google Cloud CLI** https://cloud.google.com/sdk/docs/install
* Install **jq** Linux or Mac OS only - `apt install jq` or `brew install jq` (It is using in bash scripts to create/delete Stream Manager node group using API)
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5.net/downloads
* * Download Red5 Pro Terraform controller for Google Cloud: (Example: terraform-cloud-controller-0.0.0.jar) https://account.red5.net/downloads
* Download Red5 Pro Terraform Service : (Example: terraform-service-0.0.0.zip) https://account.red5.net/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5.net
* Login to Goolge Cloud CLI (To login to CLI follow the below documents or use the below mentioned command) 
  * Follow the documentation for CLI login - https://cloud.google.com/sdk/gcloud/reference/auth/login
  * Google CLI login command `gcloud auth login`
    * Open the mentioned link in your browser:
      * Copy the `authorization code` from the browser and specify in the CLI prompt. After the successful login you will see your google cloud email detail and your cuurent project information
    * To change the current project in CLI use the below command to set the different project in CLI
      * To set different project use command `gcloud config set project PROJECT_ID`. 
* Copy Red5 Pro server build and Terraform Cloud controller to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
```

## Standalone Red5 Pro server deployment (Standalone) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/standalone)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).

## Usage (standalone)

```hcl
provider "google" {
  project                   = "example-gcp-project-name"                                     # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_standalone" {
  source                    = "red5pro/red5pro/gcp"
  google_region             = "us-west2"                                                     # Google region where resources will create eg: us-west2
  google_project_id         = "example-gcp-project-name"                                     # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version            = "22.04"                                                        # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                      = "standalone"                                                   # Deployment type: standalone, cluster, autoscale
  name                      = "red5pro-standalone"                                           # Name to be used on all the resources as identifier
  path_to_red5pro_build     = "./red5pro-server-0.0.b0-release.zip"                          # Absolute path or relative path to Red5 Pro server ZIP file

  # SSH key configuration
  create_new_ssh_keys              = true                                                    # true - create new SSH key, false - use existing SSH key
  existing_public_ssh_key_path     = "./example-ssh-key.pub"                                 # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-ssh-key.pem"                                 # if `create_new_ssh_keys` = false, Path to existing SSH private key

  # VPC configuration
  vpc_create                                        = true                                   # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name                         = "example-vpc-name"                     # if `vpc_create` = false, Existing VPC name used for the network configuration in Google Cloud
  red5_standalone_ssh_connection_source_ranges      = ["YOUR-PUBLIC-IP/32", "1.2.3.4/32"]    # List of IP address ranges to provide SSH connection with red5 server. Kindly provide your public IP to make SSH connection while running this terraform module
  create_new_firewall_for_standalone_server         = true                                   # True - Create a new firewall for Red5 Standalone server, False - Use existing firewall rule using network tag
  new_or_existing_network_tag_for_standalone_server = "example-standalone-server-instance"   # Specify the Network Tag for Red5 Standalone Server instance to be used by the Virtual Network firewall. If `vpc_create = true` specify new network tag for standalone server, if `vpc_create = false` specify existing network tag for standalone server

  # Standalone Red5 Pro server Instance configuration
  standalone_server_instance_type                   = "n2-standard-2"                        # Instance type for Red5 Pro server
  standalone_server_boot_disk_type                  = "pd-ssd"                               # Boot disk type for Standalone server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`

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
  
  
  # Standalone Red5 Pro server HTTPS (SSL) certificate configuration
  https_ssl_certificate                         = "none"                                     # none - do not use HTTPS/SSL certificate, letsencrypt - create new Let's Encrypt HTTPS/SSL certificate, imported - use existing HTTPS/SSL certificate

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

output "module_output" {
  sensitive = true
  value = module.red5pro_standalone
}
```

---

## Red5 Pro Stream Manager cluster deployment (cluster) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/cluster)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Kafka Server** - Uesrs can choose to create a dedicated instance for Kafka Server or install it locally on the Stream Manager
* **Red5 Node Image** - To create Google Cloud(Gcloud) custom image of Node for Stream Manager node group

## Usage (cluster)

```hcl
provider "google" {
  project                    = "example-gcp-project-name"                                  # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_cluster" {
  source                           = "red5pro/red5pro/gcp"
  google_region                    = "us-west2"                                            # Google region where resources will create eg: us-west2
  google_project_id                = "example-gcp-project-name"                            # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version                   = "22.04"                                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                             = "cluster"                                             # Deployment type: single, cluster, autoscale
  name                             = "red5pro-cluster"                                     # Name to be used on all the resources as identifier
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

  # Red5 Pro general configuration
  red5pro_license_key                        = "1111-2222-3333-4444"                       # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable                         = true                                        # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                            = "examplekey"                                # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Kafka Service configuration
  kafka_standalone_instance_create             = true                                      # true - Create a dedicate kafka service instance, false - install kafka service locally on the stream manager
  kafka_standalone_boot_disk_type              = "pd-ssd"                                  # Boot disk type for Kafka server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  kafka_standalone_instance_type               = "n2-standard-2"                           # Kafka service Instance type
  kafka_standalone_disk_size                   = 50                                        # Kafka server boot size in GB
  
  # Red5 Pro server Instance configuration
  stream_manager_auth_user                   = "example_user"                              # Stream Manager 2.0 authentication user name
  stream_manager_auth_password               = "example_password"                          # Stream Manager 2.0 authentication password
  stream_manager_server_instance_type        = "n2-standard-2"                             # Instance type for Red5 Pro stream manager server
  stream_manager_server_boot_disk_type       = "pd-ssd"                                    # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  stream_manager_server_disk_size            = 50                                          # Stream Manager server boot size in GB
  create_new_reserved_ip_for_stream_manager  = true                                        # True - Create a new reserved IP for stream manager, False - Use already created reserved IP address
  existing_sm_reserved_ip_name               = "example-reserved-ip"                       # If `create_new_reserved_ip_for_stream_manager` = false then specify the name of already create reserved IP for stream manager in the provided region.


  # Red5 Pro cluster node image configuration
  node_image_create                          = true                                        # Default: true for Autoscaling and Cluster, true - create new node image, false - not create new node image
  node_server_instance_type                  = "n2-standard-2"                             # Instance type for the Red5 Pro Node server
  node_server_boot_disk_type                 = "pd-ssd"                                    # Boot disk type for Node server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  
  # Red5 Pro server HTTPS (SSL) certificate configuration
  https_ssl_certificate                      = "none"                                      # none - do not use HTTPS/SSL certificate, letsencrypt - create new Let's Encrypt HTTPS/SSL certificate, imported - use existing HTTPS/SSL certificate

  # # Example of Let's Encrypt HTTPS/SSL certificate configuration - please uncomment and provide your domain name and email
  # https_ssl_certificate                    = "letsencrypt"
  # https_ssl_certificate_domain_name        = "red5pro.example.com"
  # https_ssl_certificate_email              = "email@example.com"

  # # Example of imported HTTPS/SSL certificate configuration - please uncomment and provide your domain name, certificate and key paths
  # https_ssl_certificate                    = "imported"
  # https_ssl_certificate_domain_name        = "red5pro.example.com"
  # https_ssl_certificate_cert_path          = "/PATH/TO/SSL/CERT/fullchain.pem"
  # https_ssl_certificate_key_path           = "/PATH/TO/SSL/KEY/privkey.pem"

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
  value = module.red5pro_cluster
}
```

## Red5 Pro Stream Manager autoscale deployment (autoscale) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/autoscale)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall for Stream Manager and nodes in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **Load Balancer** -  This Terrform module create a Load Balancer for Stream Manager in Google Cloud.
* **SSL Certificates** - This Terraform Module can create or use existing SSL certificate for Load Balancer
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Kafka Server** - This will create a dedicated instance for Kafka Service
* **Red5 Node Image** - To create Google Cloud(Gcloud) custom image of Node for Stream Manager node group

## Usage (autoscale)

```hcl
provider "google" {
  project                    = "example-gcp-project-name"                                  # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_autoscale" {
  source                           = "red5pro/red5pro/gcp"
  google_region                    = "us-west2"                                            # Google region where resources will create eg: us-west2
  google_project_id                = "example-gcp-project-name"                            # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version                   = "22.04"                                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                             = "autoscale"                                           # Deployment type: single, cluster, autoscale
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
  new_or_existing_network_tag_for_kafka_standalone = "example-kafka-service-instance"      # Specify the new or existing Network Tag for Kafka Service to be used by the Virtual Network firewall. If `vpc_create = true` specify new network tag, if `vpc_create = false` specify existing network tag for Kafka Service
  new_or_existing_network_tag_for_stream_manager    = "example-sm-instance"                # Specify the new or existing Network Tag for Stream Manager to be used by the Virtual Network firewall. If `vpc_create = true` specify new network tag, if `vpc_create = false` specify existing network tag for stream manager

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
```

---

**NOTES**

* To activate HTTPS/SSL you need to add DNS A record for Elastic IP (single/cluster) or CNAME record for Load Balancer DNS name (autoscaling)

---

