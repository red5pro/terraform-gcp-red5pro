## Cluster Red5 Pro server deployment (cluster)

* **VPC** - This Terrform module can either create a new or use your existing VPC. If you wish to create a new VPC, set `vpc_create` to `true`, and the script will ignore the other VPC configurations. To use your existing VPC, set `vpc_create` to `false` and include your existing vpc name.
* **SSH Keys** -This terraform module can create a new SSH keys or use the already created SSH keys.
* **Firewall** - This Terrform module create a new firewall for Red5 node, stream manager and kafka server in Google Cloud.
* **Instance Size** - Select the appropriate instance size based on the usecase from Google Cloud.
* **Stream Manager** - Instance will be created automatically for Stream Manager
* **Kafka Server** - Users can choose to create a dedicated instance for Kafka Server or install it locally on the Stream Manager
* **Red5 Node Image** - To create Google Cloud(Gcloud) custom image of Node for Stream Manager node group
* **SSL Certificates** - SSL certificate for Standalone Red5 Pro server instance. Options:
  - `none` - Stream Manager 2.0 without HTTPS and SSL certificate. Only HTTP on port `80`
  - `letsencrypt` - Stream Manager 2.0 with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `80`, HTTPS on port `443`
  - `imported` - Stream Manager 2.0 with HTTPS and imported SSL certificate. HTTP on port `80`, HTTPS on port `443`

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
