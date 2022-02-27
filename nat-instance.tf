resource "yandex_compute_instance" "nat" {
  name        = "nat"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-network-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
  }

}
