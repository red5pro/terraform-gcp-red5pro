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
  description = "Stream Manager HTTPS URL (hostname from stream_manager_public_hostname, not https_ssl_certificate_domain_name — supports wildcard certs)"
  value       = local.cluster_or_autoscale && var.https_ssl_certificate != "none" && var.stream_manager_public_hostname != "" ? "https://${var.stream_manager_public_hostname}:443" : ""

}
output "manual_dns_record" {
  description = "DNS hint for TLS: cluster/autoscale uses stream_manager_public_hostname; standalone uses https_ssl_certificate_domain_name"
  value       = var.https_ssl_certificate != "none" ? ( local.cluster_or_autoscale ? "Please create DNS A record for Stream Manager 2.0: '${var.stream_manager_public_hostname}' -> '${local.stream_manager_ip}'" : "Please create DNS A record for Standalone Red5 Pro: '${var.https_ssl_certificate_domain_name}' -> '${local.standalone_server_ip}'" ) : ""
}