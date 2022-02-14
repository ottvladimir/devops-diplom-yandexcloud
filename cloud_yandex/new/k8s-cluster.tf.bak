resource "yandex_kubernetes_cluster" "my_cluster" {
  name        = "phpadmin"
  description = "description"

  network_id = "${yandex_vpc_network.ya-network.id}"

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = "${yandex_vpc_subnet.ya-network-pub-a.zone}"
        subnet_id = "${yandex_vpc_subnet.ya-network-pub-a.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.ya-network-pub-b.zone}"
        subnet_id = "${yandex_vpc_subnet.ya-network-pub-b.id}"
      }

      location {
        zone      = "${yandex_vpc_subnet.ya-network-pub-c.zone}"
        subnet_id = "${yandex_vpc_subnet.ya-network-pub-c.id}"
      }
    }

   version   = "1.21"
    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }

      maintenance_window {
        day        = "friday"
        start_time = "10:00"
        duration   = "4h30m"
      }
    }
  }

  service_account_id      = "${yandex_iam_service_account.k8s.id}"
  node_service_account_id = "${yandex_iam_service_account.node.id}"

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel = "STABLE"
  network_policy_provider = "CALICO"
    kms_provider {
    key_id = "${yandex_kms_symmetric_key.key-a.id}"
    }
}



