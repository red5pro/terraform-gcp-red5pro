## Autoscaling Red5 Pro server deployment (autoscaling)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall for Stream Manager and nodes in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **Load Balancer** -  This Terrform module create a Load Balancer for Stream Manager in Google Cloud.
* **SSL Certificates** - This Terraform Module can create or use existing SSL certificate for Load Balancer
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Kafka Server** - Uesrs can choose to create a dedicated instance for Kafka Server or install it locally on the Stream Manager
* **Red5 Node Image** - To create Google Cloud(Gcloud) custom image of Node for Stream Manager node group

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
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
| <a name="output_google_cloud_project_id"></a> [google\_cloud\_project\_id](#output\_google\_cloud\_project\_id) | Google Cloud Project ID where resources has been created |
| <a name="output_load_balancer_url"></a> [load\_balancer\_url](#output\_load\_balancer\_url) | Load Balancer HTTPS URL |
| <a name="output_manual_dns_record"></a> [manual\_dns\_record](#output\_manual\_dns\_record) | Manual DNS record |
| <a name="output_module_output"></a> [module\_output](#output\_module\_output) | n/a |
| <a name="output_red5pro_node_image"></a> [red5pro\_node\_image](#output\_red5pro\_node\_image) | Image name of the Red5 Pro Node image |
| <a name="output_ssh_key_path"></a> [ssh\_key\_path](#output\_ssh\_key\_path) | Private SSH key path |
| <a name="output_stream_manager_http_url"></a> [stream\_manager\_http\_url](#output\_stream\_manager\_http\_url) | Stream Manager HTTP URL |
| <a name="output_stream_manager_https_url"></a> [stream\_manager\_https\_url](#output\_stream\_manager\_https\_url) | Stream Manager HTTPS URL |
| <a name="output_stream_manager_ip"></a> [stream\_manager\_ip](#output\_stream\_manager\_ip) | Stream Manager IP |
| <a name="output_vpc_netwrok_name"></a> [vpc\_netwrok\_name](#output\_vpc\_netwrok\_name) | VPC Network name used in Google Cloud |