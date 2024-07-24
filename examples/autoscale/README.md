## Autoscaling Red5 Pro server deployment (autoscaling)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall for Stream Manager and nodes in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **Load Balancer** -  This Terrform module create a Load Balancer for Stream Manager in Google Cloud.
* **SSL Certificates** - This Terraform Module can create or use existing SSL certificate for Load Balancer
* **MySQL Database** - This Terraform Module create a MySQL databse server in Google Cloud.
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Terraform Server** - This will create a dedicated instance for Terrform Service
* **Origin Node Image** - To create Google Cloud(Gcloud) custom image for Orgin Node type for Stream Manager node group
* **Edge Node Image** - To create Google Cloud(Gcloud) custom image for Edge Node type for Stream Manager node group (optional)
* **Transcoder Node Image** - To create Google Cloud(Gcloud) custom image for Transcoder Node type for Stream Manager node group (optional)
* **Relay Node Image** - To create Google Cloud(Gcloud) custom image for Relay Node type for Stream Manager node group (optional)

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
cp ~/Downloads/terraform-cloud-controller-0.0.0.jar ./
cp ~/Downloads/terraform-service-0.0.0.zip ./
```

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Notes

* To activate HTTPS/SSL you need to add DNS A record for Elastic IP of Red5 Pro server
* Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_red5pro_autoscaling"></a> [red5pro\_autoscaling](#module\_red5pro\_autoscaling) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_host"></a> [database\_host](#output\_database\_host) | MySQL database host |
| <a name="output_database_password"></a> [database\_password](#output\_database\_password) | Database Password |
| <a name="output_database_port"></a> [database\_port](#output\_database\_port) | Database Port |
| <a name="output_database_user"></a> [database\_user](#output\_database\_user) | Database User |
| <a name="output_google_cloud_project_id"></a> [google\_cloud\_project\_id](#output\_google\_cloud\_project\_id) | Google Cloud Project ID where resources has been created |
| <a name="output_load_balancer_url"></a> [load\_balancer\_url](#output\_load\_balancer\_url) | Load Balancer HTTPS URL |
| <a name="output_module_output"></a> [module\_output](#output\_module\_output) | n/a |
| <a name="output_node_edge_image"></a> [node\_edge\_image](#output\_node\_edge\_image) | Image name of the Red5 Pro Node Edge image |
| <a name="output_node_origin_image"></a> [node\_origin\_image](#output\_node\_origin\_image) | Image name of the Red5 Pro Node Origin image |
| <a name="output_node_relay_image"></a> [node\_relay\_image](#output\_node\_relay\_image) | Image name of the Red5 Pro Node Relay image |
| <a name="output_node_transcoder_image"></a> [node\_transcoder\_image](#output\_node\_transcoder\_image) | Image name of the Red5 Pro Node Transcoder image |
| <a name="output_ssh_key_path"></a> [ssh\_key\_path](#output\_ssh\_key\_path) | Private SSH key path |
| <a name="output_stream_manager_http_url"></a> [stream\_manager\_http\_url](#output\_stream\_manager\_http\_url) | Stream Manager HTTP URL |
| <a name="output_stream_manager_https_url"></a> [stream\_manager\_https\_url](#output\_stream\_manager\_https\_url) | Stream Manager HTTPS URL |
| <a name="output_stream_manager_ip"></a> [stream\_manager\_ip](#output\_stream\_manager\_ip) | Stream Manager IP |
| <a name="output_terraform_service_ip"></a> [terraform\_service\_ip](#output\_terraform\_service\_ip) | Terraform Service Host |
| <a name="output_vpc_netwrok_name"></a> [vpc\_netwrok\_name](#output\_vpc\_netwrok\_name) | VPC Network name used in Google Cloud |
