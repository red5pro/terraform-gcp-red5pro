# Google Cloud Red5 Pro Terraform module
[Red5 Pro](https://www.red5.net/) is a real-time video streaming server plaform known for its low-latency streaming capabilities, making it ideal for interactive applications like online gaming, streaming events and video conferencing etc.

This a reusable Terraform installer module for [Red5 Pro](https://www.red5.net/docs/installation/installation/googlecloudvminstall/) that provisions infrastucture over [Google Cloud(Gcloud)](https://console.cloud.google.com/).

## This module has 3 variants of Red5 Pro deployments

* **single** - Single instance with installed and configured Red5 Pro server
* **cluster** - Stream Manager cluster (MySQL DB + Stream Manager instance + Autoscaling Node group with Origin, Edge, Transcoder, Relay droplets)
* **autoscaling** - Autoscaling Stream Managers (MySQL DB + Load Balancer + Autoscaling Stream Managers + Autoscaling Node group with Origin, Edge, Transcoder, Relay droplets)

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
* Download Red5 Pro Google controller for Google CLoud: (Example: google-cloud-controller-0.0.0.jar) https://account.red5.net/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5.net
* Login to Goolge Cloud CLI (To login to CLI follow the below documents or use the below mentioned command) 
  * Follow the documentation for CLI login - https://cloud.google.com/sdk/gcloud/reference/auth/login
  * Google CLI login command `gcloud auth login`
    * Open the mentioned link in your browser:
      * Copy the `authorization code` from the browser and specify in the CLI prompt. After the successful login you will see your google cloud email detail and your cuurent project information
    * To change the current project in CLI use the below command to set the different project in CLI
      * To set different project use command `gcloud config set project PROJECT_ID`. 
* Copy Red5 Pro server build and Google Cloud controller to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
cp ~/Downloads/google-cloud-controller-0.0.0.jar ./
```

## Single Red5 Pro server deployment (single) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/single)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).

## Usage (single)

```hcl
provider "google" {
  project                   = "example-gcp-project-name"                                     # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_single" {
  source                    = "red5pro/red5pro/gcp"
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
```

---

## Red5 Pro Stream Manager cluster deployment (cluster) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/cluster)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).
* **MySQL Database** - Users have flexibility to create a MySQL databse server in Google Cloud or install it locally on the Stream Manager
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Origin Node Image** - To create Google Cloud(Gcloud) custom image for Orgin Node type for Stream Manager node group
* **Edge Node Image** - To create Google Cloud(Gcloud) custom image for Edge Node type for Stream Manager node group (optional)
* **Transcoder Node Image** - To create Google Cloud(Gcloud) custom image for Transcoder Node type for Stream Manager node group (optional)
* **Relay Node Image** - To create Google Cloud(Gcloud) custom image for Relay Node type for Stream Manager node group (optional)

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
  type                             = "cluster"                                             # Deployment type: single, cluster, autoscaling
  name                             = "red5pro-cluster"                                     # Name to be used on all the resources as identifier
  path_to_red5pro_build            = "./red5pro-server-0.0.0.b0-release.zip"               # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_google_cloud_controller  = "./google-cloud-controller-0.0.0.jar"                 # Absolute path or relative path to google cloud controller jar file
 
  # SSH key configuration
  create_new_ssh_keys              = true                                                  # true - create new SSH key, false - use existing SSH key
  new_ssh_key_name                 = "example-ssh-key"                                     # if `create_new_ssh_keys` = true, Name for new SSH key
  existing_public_ssh_key_path     = "./example-ssh-key.pub"                               # if `create_new_ssh_keys` = false, Path to existing SSH public key
  existing_private_ssh_key_path    = "./example-ssh-key.pem"                               # if `create_new_ssh_keys` = false, Path to existing SSH private key
  
  # VPC configuration
  vpc_create                       = true                                                  # True - Create a new VPC in Google Cloud, False - Use existing VPC
  existing_vpc_network_name        = "example-vpc-name"                                    # if `vpc_create` = false, Existing VPC name used for the network configuration

  # Database Configuration
  mysql_database_create            = false                                                 # true - create a new database false- Install locally
  mysql_instance_type              = "db-n1-standard-2"                                    # New database instance type (https://cloud.google.com/sdk/gcloud/reference/sql/tiers/list)
  mysql_username                   = "example-user"                                        # Username for locally install databse and dedicated database in google
  mysql_password                   = "ExamplePassword123"                                  # Password for locally install databse and dedicated database in google
  mysql_port                       = 3306                                                  # Port for locally install databse and dedicated database in google

  # Red5 Pro general configuration
  red5pro_license_key                        = "1111-2222-3333-4444"                       # Red5 Pro license key (https://account.red5.net/login)
  red5pro_cluster_key                        = "examplekey"                                # Red5 Pro cluster key
  red5pro_api_enable                         = true                                        # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                            = "examplekey"                                # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Red5 Pro server HTTPS/SSL certificate configuration
  https_letsencrypt_enable                   = false                                       # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name  = "red5pro.example.com"                       # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email        = "email@example.com"                         # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password     = "examplepass"                               # Password for Let's Encrypt SSL certificate
  
  # Red5 Pro server Instance configuration
  create_new_reserved_ip_for_stream_manager  = true                                        # True - Create a new reserved IP for stream manager, False - Use already created reserved IP address
  existing_sm_reserved_ip_name               = "1.2.3.4"                                   # If `create_new_reserved_ip_for_stream_manager` = false then specify the name of already create reserved IP for stream manager in the provided region.
  stream_manager_server_instance_type        = "n2-standard-2"                             # Instance type for Red5 Pro stream manager server
  stream_manager_api_key                     = "examplekey"                                # Stream Manager api key
  stream_manager_server_boot_disk_type       = "pd-ssd"                                    # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`

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
  node_group_origins                    = 1                                                # Number of Origins
  node_group_origins_instance_type      = "n2-standard-2"                                  # Origins google instance
  node_group_origins_capacity           = 20                                               # Connections capacity for Origins
  # Edge node configuration
  node_group_edges                      = 1                                                # Number of Edges
  node_group_edges_instance_type        = "n2-standard-2"                                  # Edges google instance
  node_group_edges_capacity             = 200                                              # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders                = 0                                                # Number of Transcoders
  node_group_transcoders_instance_type  = "n2-standard-2"                                  # Transcoders google instance
  node_group_transcoders_capacity       = 20                                               # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays                     = 0                                                # Number of Relays
  node_group_relays_instance_type       = "n2-standard-2"                                  # Relays google instance
  node_group_relays_capacity            = 20                                               # Connections capacity for Relays
}

output "module_output" {
  sensitive = true
  value = module.red5pro_cluster
}
```

## Red5 Pro Stream Manager autoscale deployment (autoscaling) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/autoscaling)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall for Stream Manager and nodes in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **Load Balancer** -  This Terrform module create a Load Balancer for Stream Manager in Google Cloud.
* **SSL Certificates** - This Terraform Module can create or use existing SSL certificate for Load Balancer
* **MySQL Database** - This Terraform Module create a MySQL databse server in Google Cloud.
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Origin Node Image** - To create Google Cloud(Gcloud) custom image for Orgin Node type for Stream Manager node group
* **Edge Node Image** - To create Google Cloud(Gcloud) custom image for Edge Node type for Stream Manager node group (optional)
* **Transcoder Node Image** - To create Google Cloud(Gcloud) custom image for Transcoder Node type for Stream Manager node group (optional)
* **Relay Node Image** - To create Google Cloud(Gcloud) custom image for Relay Node type for Stream Manager node group (optional)

## Usage (autoscaling)

```hcl
provider "google" {
  project                    = "example-gcp-project-name"                                  # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro_autoscaling" {
  source                           = "red5pro/red5pro/gcp"
  google_region                    = "us-west2"                                            # Google region where resources will create eg: us-west2
  google_project_id                = "example-gcp-project-name"                            # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version                   = "22.04"                                               # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                             = "autoscaling"                                         # Deployment type: single, cluster, autoscaling
  name                             = "red5pro-autoscaling"                                 # Name to be used on all the resources as identifier
  path_to_red5pro_build            = "./red5pro-server-0.0.0.b0-release.zip"               # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_google_cloud_controller  = "./google-cloud-controller-0.0.0.jar"                 # Absolute path or relative path to google cloud controller jar file

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

# Load Balancer Configuration
  count_of_stream_managers             = 1                                                 # Amount of Stream Managers to deploy in autoscale setup
  create_new_lb_ssl_cert               = true                                              # True - Create a new SSL certificate for the Load Balancer, False - Use existing SSL certificate for Load Balancer
  new_ssl_private_key_path             = "/path/to/privkey.pem"                            # if `create_new_lb_ssl_cert` = true, Path to the new SSL certificate private key file
  new_ssl_certificate_key_path         = "/path/to/fullchain.pem"                          # if `create_new_lb_ssl_cert` = true, Path to the new SSL certificate key file
  existing_ssl_certificate_name        = "example-certificate-name"                        # if `create_new_lb_ssl_cert` = false, Existing SSL certificate name which is already created in the Google Cloud. If creating a new project in GCP, kindly create a new SSL certificate

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
  node_group_origins                    = 1                                                # Number of Origins
  node_group_origins_instance_type      = "n2-standard-2"                                  # Origins google instance
  node_group_origins_capacity           = 20                                               # Connections capacity for Origins
  # Edge node configuration
  node_group_edges                      = 1                                                # Number of Edges
  node_group_edges_instance_type        = "n2-standard-2"                                  # Edges google instance
  node_group_edges_capacity             = 200                                              # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders                = 0                                                # Number of Transcoders
  node_group_transcoders_instance_type  = "n2-standard-2"                                  # Transcoders google instance
  node_group_transcoders_capacity       = 20                                               # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays                     = 0                                                # Number of Relays
  node_group_relays_instance_type       = "n2-standard-2"                                  # Relays google instance
  node_group_relays_capacity            = 20                                               # Connections capacity for Relays
}

output "module_output" {
  sensitive = true
  value = module.red5pro_autoscaling
}
```

---

**NOTES**

* To activate HTTPS/SSL you need to add DNS A record for Elastic IP (single/cluster) or CNAME record for Load Balancer DNS name (autoscaling)

---

