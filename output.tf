################################################################################
# OUTPUTS
################################################################################
output "red5pro_node_image" {
  description = "Image name of the Red5 Pro Node Origin image"
  value       = try(google_compute_image.red5_node_image[0].name, "")
}
output "google_cloud_project_id" {
  description = "Google Cloud Project ID where resources has been created"
  value       = local.google_cloud_project
}
output "google_cloud_vpc_netwrok_name" {  
  description = "VPC Network name used in Google Cloud"
  value       = local.vpc_network_name
}
output "ssh_private_key_path" {
  description = "Private SSH key path"
  value       = local.ssh_private_key_path
}
output "standalone_red5pro_server_url_http" {
  description = "Standalone Red5 Pro Server HTTP URL"
  value       = local.standalone ? "http://${local.standalone_server_ip}:5080" : ""
}
output "standalone_red5pro_server_url_https" {
  description = "Standalone Red5 Pro Server HTTPS URL"
  value       = local.standalone && var.https_ssl_certificate != "none" ? "https://${var.https_ssl_certificate_domain_name}:443" : ""
}
output "standalone_red5pro_server_ip" {
  description = "Standalone Red5 Pro Server IP"
  value       = local.standalone_server_ip
}
output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = local.stream_manager_ip
}
output "stream_manager_url_http" {
  description = "Stream Manager HTTP URL"
  value       = local.cluster_or_autoscale ? "http://${local.stream_manager_ip}:80" : ""
}
output "stream_manager_url_https" {
  description = "Stream Manager HTTPS URL"
  value       = var.https_ssl_certificate != "none" ? local.cluster ? "https://${var.https_ssl_certificate_domain_name}:443" : local.autoscale ? "https://${local.stream_manager_ip}:443" : "" : ""
}
output "manual_dns_record" {
  description = "Manual DNS Record"
  value       = var.https_ssl_certificate != "none" ? "Please create DNS A record for Stream Manager 2.0: '${local.autoscale ? "your.domain.name" : var.https_ssl_certificate_domain_name} - ${local.cluster_or_autoscale ? local.stream_manager_ip : local.standalone_server_ip}'" : null
}