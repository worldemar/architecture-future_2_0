output "app_external_ip" {
  value = yandex_compute_instance.app_vm.network_interface.0.nat_ip_address
  description = "External IP address of the Application Server"
}

output "app_internal_ip" {
  value = yandex_compute_instance.app_vm.network_interface.0.ip_address
  description = "Internal IP address of the Application Server"
}

output "db_internal_ip" {
  value = yandex_compute_instance.db_vm.network_interface.0.ip_address
  description = "Internal IP address of the Database Server"
}
