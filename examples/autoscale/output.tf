output "node_origin_image" {
  description = "Image name of the Red5 Pro Node Origin image"
  value       = module.red5pro_autoscaling.node_origin_image
}

output "node_edge_image" {
  description = "Image name of the Red5 Pro Node Edge image"
  value       = module.red5pro_autoscaling.node_edge_image
}

output "node_transcoder_image" {
  description = "Image name of the Red5 Pro Node Transcoder image"
  value       = module.red5pro_autoscaling.node_transcoder_image
}

output "node_relay_image" {
  description = "Image name of the Red5 Pro Node Relay image"
  value       = module.red5pro_autoscaling.node_relay_image
}

output "google_cloud_project_id" {
  description = "Google Cloud Project ID where resources has been created"
  value       = module.red5pro_autoscaling.google_cloud_project_id
}

output "vpc_netwrok_name" {  
  description = "VPC Network name used in Google Cloud"
  value       = module.red5pro_autoscaling.google_cloud_vpc_netwrok_name
}

output "ssh_key_path" {
  description = "Private SSH key path"
  value       = module.red5pro_autoscaling.ssh_key_path
}

output "database_host" {
  description = "MySQL database host"
  value       = module.red5pro_autoscaling.database_host
}

output "database_user" {
  description = "Database User"
  value       = module.red5pro_autoscaling.database_user
}

output "database_port" {
  description = "Database Port"
  value       = module.red5pro_autoscaling.database_port
}

output "database_password" {
  sensitive   = true
  description = "Database Password"
  value       = module.red5pro_autoscaling.database_password
}

output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = module.red5pro_autoscaling.stream_manager_ip
}

output "stream_manager_http_url" {
  description = "Stream Manager HTTP URL"
  value       = module.red5pro_autoscaling.stream_manager_http_url
}

output "stream_manager_https_url" {
  description = "Stream Manager HTTPS URL"
  value       = module.red5pro_autoscaling.stream_manager_https_url
}

output "load_balancer_url" {
  description = "Load Balancer HTTPS URL"
  value       = module.red5pro_autoscaling.load_balancer_url
}