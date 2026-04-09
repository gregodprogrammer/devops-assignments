output "frontend_public_ip" {
  description = "Public IP of the Frontend VM"
  value       = azurerm_public_ip.pip_frontend.ip_address
}

output "backend_public_ip" {
  description = "Public IP of the Backend VM"
  value       = azurerm_public_ip.pip_backend.ip_address
}
