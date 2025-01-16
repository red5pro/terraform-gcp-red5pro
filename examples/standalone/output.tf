output "ssh_private_key_path" {
    description = "SSH private key path"
    value       = module.red5pro.ssh_private_key_path
}
output "standalone_red5pro_server_ip" {
    description = "Red5 Pro Server IP"
    value       = module.red5pro.standalone_red5pro_server_ip
}
output "standalone_red5pro_server_url_http" {
    description = "Red5 Pro Server HTTP URL"
    value       = module.red5pro.standalone_red5pro_server_url_http
}
output "standalone_red5pro_server_url_https" {
    description = "Red5 Pro Server HTTPS URL"
    value       = module.red5pro.standalone_red5pro_server_url_https
}
output "vpc_network_name" {
    description = "VPC Network name"
    value       = module.red5pro.google_cloud_vpc_netwrok_name
}
output "google_project_id" {
    description = "Google Cloud Project"
    value       = module.red5pro.google_cloud_project_id
}
output "manual_dns_record" {
  description   = "Manual DNS record"
  value         = module.red5pro.manual_dns_record
}
