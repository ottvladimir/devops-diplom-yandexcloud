resource "yandex_container_registry" "diploma" {
  name      = "netology"
  folder_id = var.yc_folder_id

  labels = {
    my-label = "diploma-apps"
  }
}
