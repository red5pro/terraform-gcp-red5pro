output "ssh_private_key_path" {
    description = "SSH private key path"
    value       = module.red5pro_single.ssh_key_path
}
output "red5pro_server_ip" {
    description = "Red5 Pro Server IP"
    value       = module.red5pro_single.single_red5pro_server_ip
}
output "red5pro_server_http_url" {
    description = "Red5 Pro Server HTTP URL"
    value       = module.red5pro_single.single_red5pro_server_http_url
}
output "red5pro_server_https_url" {
    description = "Red5 Pro Server HTTPS URL"
    value       = module.red5pro_single.single_red5pro_server_https_url
}
output "vpc_network_name" {
    description = "VPC Network name"
    value       = module.red5pro_single.google_cloud_vpc_netwrok_name
}
output "google_project_name" {
    description = "Google Cloud Project"
    value       = module.red5pro_single.google_cloud_project_id
}