resource "yandex_mdb_mysql_cluster" "netology_mysql" {
  name        = "metology"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.ya-network.id
  version     = "8.0"
  deletion_protection = false 
  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  database {
    name = "netology_db"
  }
  backup_window_start {
    hours = "23"
    minutes = "59"
  }
  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  user {
    name     = "netology"
    password = "P@ssw0rd2"
    permission {
      database_name = "netology_db"
      roles         = ["ALL"]
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "mysql-a"
    subnet_id = yandex_vpc_subnet.ya-network-a.id
  }
  host {
    zone      = "ru-central1-b"
    name      = "mysql-b"
    subnet_id = yandex_vpc_subnet.ya-network-b.id
  }

  host {
    zone      = "ru-central1-c"
    name      = "mysql-c"
    subnet_id = yandex_vpc_subnet.ya-network-c.id
  }
}
