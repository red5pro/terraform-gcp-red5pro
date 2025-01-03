## Standalone Red5 Pro server deployment (standalone)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).

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
| <a name="module_red5pro_standalone"></a> [red5pro\_standalone](#module\_red5pro\_standalone) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_google_project_id"></a> [google\_project\_id](#output\_google\_project\_id) | Google Cloud Project |
| <a name="output_manual_dns_record"></a> [manual\_dns\_record](#output\_manual\_dns\_record) | Manual DNS record |
| <a name="output_module_output"></a> [module\_output](#output\_module\_output) | n/a |
| <a name="output_red5pro_server_http_url"></a> [red5pro\_server\_http\_url](#output\_red5pro\_server\_http\_url) | Red5 Pro Server HTTP URL |
| <a name="output_red5pro_server_https_url"></a> [red5pro\_server\_https\_url](#output\_red5pro\_server\_https\_url) | Red5 Pro Server HTTPS URL |
| <a name="output_red5pro_server_ip"></a> [red5pro\_server\_ip](#output\_red5pro\_server\_ip) | Red5 Pro Server IP |
| <a name="output_ssh_private_key_path"></a> [ssh\_private\_key\_path](#output\_ssh\_private\_key\_path) | SSH private key path |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | VPC Network name |
