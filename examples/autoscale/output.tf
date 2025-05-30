output "red5pro_node_image" {
  description = "Image name of the Red5 Pro Node image"
  value       = module.red5pro.red5pro_node_image
}
output "google_cloud_project_id" {
  description = "Google Cloud Project ID where resources has been created"
  value       = module.red5pro.google_cloud_project_id
}
output "vpc_netwrok_name" {  
  description = "VPC Network name used in Google Cloud"
  value       = module.red5pro.google_cloud_vpc_netwrok_name
}
output "ssh_private_key_path" {
  description = "Private SSH key path"
  value       = module.red5pro.ssh_private_key_path
}
output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = module.red5pro.stream_manager_ip
}
output "stream_manager_url_http" {
  description = "Stream Manager HTTP URL"
  value       = module.red5pro.stream_manager_url_http
}
output "stream_manager_url_https" {
  description = "Stream Manager HTTPS URL"
  value       = module.red5pro.stream_manager_url_https
}
output "manual_dns_record" {
  description = "Manual DNS record"
  value       = module.red5pro.manual_dns_record
}
