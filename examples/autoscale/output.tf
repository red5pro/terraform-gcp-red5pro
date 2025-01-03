output "red5pro_node_image" {
  description = "Image name of the Red5 Pro Node image"
  value       = module.red5pro_autoscale.red5pro_node_image
}

output "google_cloud_project_id" {
  description = "Google Cloud Project ID where resources has been created"
  value       = module.red5pro_autoscale.google_cloud_project_id
}

output "vpc_netwrok_name" {  
  description = "VPC Network name used in Google Cloud"
  value       = module.red5pro_autoscale.google_cloud_vpc_netwrok_name
}

output "ssh_key_path" {
  description = "Private SSH key path"
  value       = module.red5pro_autoscale.ssh_key_path
}

output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = module.red5pro_autoscale.stream_manager_ip
}

output "stream_manager_http_url" {
  description = "Stream Manager HTTP URL"
  value       = module.red5pro_autoscale.stream_manager_http_url
}

output "stream_manager_https_url" {
  description = "Stream Manager HTTPS URL"
  value       = module.red5pro_autoscale.stream_manager_https_url
}

output "load_balancer_url" {
  description = "Load Balancer HTTPS URL"
  value       = module.red5pro_autoscale.load_balancer_url
}

output "manual_dns_record" {
  description = "Manual DNS record"
  value       = module.red5pro_autoscale.manual_dns_record
}
