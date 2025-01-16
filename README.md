# Google Cloud Red5 Pro Terraform module
[Red5 Pro](https://www.red5.net/) is a real-time video streaming server plaform known for its low-latency streaming capabilities, making it ideal for interactive applications like online gaming, streaming events and video conferencing etc.

This a reusable Terraform installer module for [Red5 Pro](https://www.red5.net/docs/installation/installation/googlecloudvminstall/) that provisions infrastucture over [Google Cloud(Gcloud)](https://console.cloud.google.com/).

## Preparation

### Install Terraform

- Visit the [Terraform download page](https://developer.hashicorp.com/terraform/downloads) and ensure you get version 1.7.5 or higher.
- Download the suitable version for your operating system.
- Extract the compressed file and copy the Terraform binary to a location within your system's PATH.
- Configure PATH for **Linux/macOS**:
  - Open a terminal and type the following command:

    ```sh
    sudo mv /path/to/terraform /usr/local/bin
    ```

- Configure PATH for **Windows**:
  - Click 'Start', search for 'Control Panel', and open it.
  - Navigate to `System > Advanced System Settings > Environment Variables`.
  - Under System variables, find 'PATH' and click 'Edit'.
  - Click 'New' and paste the directory location where you extracted the terraform.exe file.
  - Confirm changes by clicking 'OK' and close all open windows.
  - Open a new terminal and verify that Terraform has been successfully installed.

  ```sh
  terraform --version
  ```

### Install jq

- Install **jq** (Linux or Mac OS only) [Download](https://jqlang.github.io/jq/download/)
  - Linux: `apt install jq`
  - MacOS: `brew install jq`
  > It is used in bash scripts to create/delete Stream Manager node group using API

### Red5 Pro artifacts

- Download Red5 Pro server build in your [Red5 Pro Account](https://account.red5.net/downloads). Example: `red5pro-server-0.0.0.b0-release.zip`
- Get Red5 Pro License key in your [Red5 Pro Account](https://account.red5.net/downloads). Example: `1111-2222-3333-4444`

### Install Google Cloud SDK (GCP CLI)

- [Installing the CLI](https://cloud.google.com/sdk/docs/install)

### Prepare GCP Account

- Create a service account for the Terraform module. The service account must have permission to create and manage the following resources:
  - Identity and Access Management Rights
    - Virtual Private Cloud (VPC)
    - Compute Engine Instances
    - Instance Templates
    - Autoscaling Configurations
    - Load Balancers
    - SSL Certificates

- Obtain the necessary credentials and information:
  - Service Account with appropriate roles (e.g., `roles/editor` or custom roles with the above permissions)
  - Generate and download a JSON key file for the service account
  - Project ID  
  - Region  
  - Zone

## This module has 3 variants of Red5 Pro deployments

* **standalone** - Single instance with installed and configured Red5 Pro server
* **cluster** - Stream Manager cluster (Stream Manager instance + Autoscaling Node group with Origin, Edge, Transcoder, Relay instance)
* **autoscale** - Autoscale Stream Managers (Load Balancer + Autoscaling Stream Managers + Kafka Service + Autoscaling Node group with Origin, Edge, Transcoder, Relay instance)

---

## Standalone Red5 Pro server deployment (Standalone) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/standalone)

In the following example, Terraform module will automates the infrastructure provisioning of the [Red5 Pro standalone server](https://www.red5.net/docs/installation/).

#### Terraform Deployed Resources (standalone)

- VPC 
- Public Subnet  
- Cloud Router 
- Firewall for Standalone Red5 Pro Server  
- SSH Key Pair (use existing or create a new one)  
- Standalone Red5 Pro Server Instance  
- SSL Certificate for Standalone Red5 Pro Server Instance. Options:  
  - `none`: Red5 Pro server without HTTPS and SSL certificate. Only HTTP on port `5080`  
  - `letsencrypt`: Red5 Pro server with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `5080`, HTTPS on port `443`  
  - `imported`: Red5 Pro server with HTTPS and imported SSL certificate. HTTP on port `5080`, HTTPS on port `443`

#### Example main.tf (standalone)

```yaml
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

output "module_output" {
  value = module.red5pro
}
```
---

## Red5 Pro Stream Manager cluster deployment (cluster) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/cluster)

In the following example, Terraform module will automates the infrastructure provisioning of the Stream Manager 2.0 cluster with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Terraform Deployed Resources (cluster)

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

#### Example main.tf (cluster)

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
  firewall_nodes_network_tags_existing              = ["example-tag-1"]                  # Existing network tags name for firewall configuration

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
  node_group_origins_disk_size         = 16              # Volume size for Origins
  node_group_edges_min                 = 1               # Number of minimum Edges
  node_group_edges_max                 = 20              # Number of maximum Edges
  node_group_edges_instance_type       = "n2-standard-2" # Edges google instance type
  node_group_edges_disk_size           = 16              # Volume size for Edges
  node_group_transcoders_min           = 0               # Number of minimum Transcoders
  node_group_transcoders_max           = 10              # Number of maximum Transcoders
  node_group_transcoders_instance_type = "n2-standard-2" # Transcoders google instance type
  node_group_transcoders_disk_size     = 16              # Volume size for Transcoders
  node_group_relays_min                = 0               # Number of minimum Relays
  node_group_relays_max                = 20              # Number of maximum Relays
  node_group_relays_instance_type      = "n2-standard-2" # Relays google instance type
  node_group_relays_disk_size          = 16              # Volume size for Relays
}

output "module_output" {
  value = module.red5pro
}
```

## Red5 Pro Stream Manager autoscale deployment (autoscale) - [Example](https://github.com/red5pro/terraform-gcp-red5pro/tree/master/examples/autoscale)

In the following example, Terraform module will automates the infrastructure provisioning of the Autoscale Stream Managers 2.0 with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Terraform Deployed Resources (autoscale)

- VPC
- Public Subnet
- Cloud Router 
- Firewall Rules
  - Stream Manager 2.0
  - Kafka
  - Red5 Pro (SM2.0) Autoscaling Nodes
- SSH key pair (use existing or create a new one)
- Standalone Kafka instance
- Stream Manager 2.0 instance image
- Instance pool for Stream Manager 2.0 instances
- Autoscaling configuration for Stream Manager 2.0 instances
- HTTP(S) Load Balancer for Stream Manager 2.0 instances
- SSL Certificate for HTTP(S) Load Balancer. Options:
  - `none` - HTTP(S) Load Balancer without HTTPS and SSL certificate. Only HTTP on port `80`.
  - `imported` - HTTP(S) Load Balancer with HTTPS and an imported SSL certificate in Google Cloud Certificate Manager. HTTP on port `80`, HTTPS on port `443`.
  - `existing` - HTTP(S) Load Balancer with HTTPS using an existing SSL certificate in Google Cloud Certificate Manager. HTTP on port `80`, HTTPS on port `443`.
- Red5 Pro (SM2.0) Node instance image (origins, edges, transcoders, relays)
- Red5 Pro (SM2.0) Autoscaling Node group (origins, edges, transcoders, relay)

#### Example main.tf (autoscale)

```yaml
provider "google" {
  project = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)
}

module "red5pro" {
  source            = "../../"
  google_region     = "us-west2"                 # Google region where resources will create eg: us-west2
  google_project_id = "example-gcp-project-name" # Google Cloud project ID (https://support.google.com/googleapi/answer/7014113?hl=en)

  ubuntu_version        = "22.04"                                 # The version of ubuntu which is used to create Instance, it can either be 20.04 or 22.04
  type                  = "autoscale"                             # Deployment type: standalone, cluster, autoscale
  name                  = "red5pro-autoscale"                     # Name to be used on all the resources as identifier
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
  firewall_nodes_network_tags_existing              = ["example-tag-1"]                  # Existing network tags name for firewall configuration

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Kafka Service configuration
  kafka_standalone_instance_type = "n2-standard-2" # Kafka service Instance type
  kafka_standalone_disk_type     = "pd-ssd"        # Boot disk type for Kafka server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  kafka_standalone_disk_size     = 24              # Kafka server boot size in GB

  # Stream Manager configuration
  stream_manager_auth_user                = "example_user"     # Stream Manager 2.0 authentication user name
  stream_manager_auth_password            = "example_password" # Stream Manager 2.0 authentication password
  stream_manager_instance_type            = "n2-standard-2"    # Instance type for Red5 Pro stream manager server
  stream_manager_disk_type                = "pd-ssd"           # Boot disk type for Stream Manager server. Possible values are `pd-ssd`, `pd-standard`, `pd-balanced`
  stream_manager_disk_size                = 24                 # Stream Manager server boot size in GB
  stream_manager_autoscaling_min_replicas = 1                  # Minimum capacity for Stream Manager autoscaling group
  stream_manager_autoscaling_max_replicas = 2                  # Maximum capacity for Stream Manager autoscaling group

  # Load Balancer Configuration
  lb_global_reserved_ip_use_existing  = false                 # True - Use already created reserved IP address for Load Balancer, False - Create a new reserved IP for Load Balancer
  lb_global_reserved_ip_name_existing = "example-reserved-ip" # If `lb_global_reserved_ip_use_existing` - True, Use the already created Load balancer IP address name

  # Stream Manager 2.0 Load Balancer HTTPS (SSL) certificate configuration
  https_ssl_certificate = "none" # none - do not use HTTPS/SSL certificate, imported - import existing HTTPS/SSL certificate, existing - use existing HTTPS/SSL certificate in GCP

  # Example of imported HTTPS/SSL certificate configuration - please uncomment and provide your domain name, certificate and key paths
  # https_ssl_certificate           = "imported"                 # Improt local HTTPS/SSL certificate to AWS ACM
  # https_ssl_certificate_name      = "example-certificate-name" # Name of the HTTPS/SSL certificate
  # https_ssl_certificate_cert_path = "/PATH/TO/SSL/CERT/fullchain.pem"
  # https_ssl_certificate_key_path  = "/PATH/TO/SSL/KEY/privkey.pem"

  # Example of existing HTTPS/SSL certificate configuration - please uncomment and provide your domain name
  # https_ssl_certificate      = "existing"                 # Use existing HTTPS/SSL certificate in GCP
  # https_ssl_certificate_name = "example-certificate-name" # Replace with your domain name

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
  node_group_origins_disk_size         = 16              # Volume size for Origins
  node_group_edges_min                 = 1               # Number of minimum Edges
  node_group_edges_max                 = 20              # Number of maximum Edges
  node_group_edges_instance_type       = "n2-standard-2" # Edges google instance type
  node_group_edges_disk_size           = 16              # Volume size for Edges
  node_group_transcoders_min           = 0               # Number of minimum Transcoders
  node_group_transcoders_max           = 10              # Number of maximum Transcoders
  node_group_transcoders_instance_type = "n2-standard-2" # Transcoders google instance type
  node_group_transcoders_disk_size     = 16              # Volume size for Transcoders
  node_group_relays_min                = 0               # Number of minimum Relays
  node_group_relays_max                = 20              # Number of maximum Relays
  node_group_relays_instance_type      = "n2-standard-2" # Relays google instance type
  node_group_relays_disk_size          = 16              # Volume size for Relays
}

output "module_output" {
  value = module.red5pro
}
```
---

**NOTES**

> - WebRTC broadcast does not work in WEB browsers without an HTTPS (SSL) certificate.
> - To activate HTTPS/SSL, you need to add a DNS A record for the Public/Reserved IP address of your Red5 Pro server or Stream Manager 2.0.

---
