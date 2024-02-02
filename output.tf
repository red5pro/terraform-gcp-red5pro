################################################################################
# OUTPUTS
################################################################################
output "node_origin_image" {
  description = "Image name of the Red5 Pro Node Origin image"
  value       = try(google_compute_image.red5_origin_image[0].name, null)
}

output "node_edge_image" {
  description = "Image name of the Red5 Pro Node Edge image"
  value       = try(google_compute_image.red5_edge_image[0].name, null)
}

output "node_transcoder_image" {
  description = "Image name of the Red5 Pro Node Transcoder image"
  value       = try(google_compute_image.red5_transcoder_image[0].name, null)
}

output "node_relay_image" {
  description = "Image name of the Red5 Pro Node Relay image"
  value       = try(google_compute_image.red5_relay_image[0].name, null)
}

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

output "database_host" {
  description = "MySQL database host"
  value       = local.mysql_host
}

output "database_user" {
  description = "Database User"
  value       = var.mysql_username
}

output "database_port" {
  description = "Database Port"
  value       = var.mysql_port
}

output "database_password" {
  sensitive   = true
  description = "Database Password"
  value       = var.mysql_password
}

output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = local.stream_manager_ip
}

output "stream_manager_http_url" {
  description = "Stream Manager HTTP URL"
  value       = local.cluster ? "http://${local.stream_manager_ip}:5080" : null
}

output "stream_manager_https_url" {
  description = "Stream Manager HTTPS URL"
  value       = local.cluster && var.https_letsencrypt_enable ? "https://${var.https_letsencrypt_certificate_domain_name}:443" : null
}