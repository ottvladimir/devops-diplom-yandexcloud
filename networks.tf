# Create ya.cloud VPC
resource "yandex_vpc_network" "k8s-network" {
  name = "ya-network"
}
# Create ya.cloud public subnet
resource "yandex_vpc_subnet" "k8s-network-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.0.0/24"]
}
resource "yandex_vpc_subnet" "k8s-network-b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.10.0/24"]
}
resource "yandex_vpc_subnet" "k8s-network-c" {
  name           = "public-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.20.0/24"]
}
# Create ya.cloud private subnet
#resource "yandex_vpc_subnet" "ya-network-a" {
#  name           = "private-a"
#  zone           = "ru-central1-a"
#  network_id     = yandex_vpc_network.ya-network.id
#  v4_cidr_blocks = ["192.168.20.0/24"]
#  route_table_id = yandex_vpc_route_table.route-table.id
#}
#resource "yandex_vpc_subnet" "ya-network-b" {
#  name           = "private-b"
#  zone           = "ru-central1-b"
#  network_id     = yandex_vpc_network.ya-network.id
#  v4_cidr_blocks = ["192.168.30.0/24"]
#  route_table_id = yandex_vpc_route_table.route-table.id
#}
#resource "yandex_vpc_subnet" "ya-network-c" {
#  name           = "private-c"
#  zone           = "ru-central1-c"
#  network_id     = yandex_vpc_network.ya-network.id
#  v4_cidr_blocks = ["192.168.40.0/24"]
#  route_table_id = yandex_vpc_route_table.route-table.id
#}
#resource "yandex_vpc_route_table" "route-table" {
#  name = "nat-route"
#  network_id = yandex_vpc_network.ya-network.id
#
#  static_route {
#    destination_prefix = "0.0.0.0/0"
#    next_hop_address   = yandex_compute_instance.nat.network_interface[0].ip_address
#  }
#}
