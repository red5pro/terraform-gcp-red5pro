output "google_cloud_project_id" {
  description = "Google Cloud Project ID where resources has been created"
  value       = local.google_cloud_project
}

output "google_cloud_vpc_netwrok_name" {  
  description = "VPC Network name used in Google Cloud"
  value       = local.vpc_network_name
}

output "ssh_key_path" {
  description = "Private SSH key path"
  value       = local.ssh_private_key_path
}

output "single_red5pro_server_http_url" {
  description = "Single Red5 Pro Server HTTP URL"
  value       = local.single ? "http://${local.single_server_ip}:5080" : null
}

output "single_red5pro_server_https_url" {
  description = "Single Red5 Pro Server HTTPS URL"
  value       = local.single && var.https_letsencrypt_enable ? "https://${var.https_letsencrypt_certificate_domain_name}:443" : null
}

output "single_red5pro_server_ip" {
  description = "Single Red5 Pro Server IP"
  value       = local.single_server_ip
}