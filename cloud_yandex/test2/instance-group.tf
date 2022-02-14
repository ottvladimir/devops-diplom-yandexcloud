resource "yandex_compute_instance_group" "k8s-cluster" {
  name                = "k8s-cluster"
  folder_id           = var.yc_folder_id
  service_account_id  = var.sa_id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    name = "${terraform.workspace}-worker-{instance.index}"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 10
      }
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s-network-a.id,
                    yandex_vpc_subnet.k8s-network-b.id,
                    yandex_vpc_subnet.k8s-network-c.id]
      nat = true
    }
    metadata = {
      ssh-keys = "ubuntu:id_rsa.pub}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a",
             "ru-central1-b",
             "ru-central1-c"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 2
    max_deleting    = 2
  }
  load_balancer {
    target_group_name        = "${terraform.workspace}-target-group"
    target_group_description = "${terraform.workspace} load balancer target group"
  }
}
