output "instance_group_public_ips" {
  description = "Public IP addresses for k8s-nodes"
  value = yandex_compute_instance_group.k8s-cluster.instances.*.network_interface.0.nat_ip_address
}

