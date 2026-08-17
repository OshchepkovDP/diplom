# Yandex Container Registry для Docker-образов
resource "yandex_container_registry" "diploma" {
  name      = "diploma-registry"
  folder_id = var.yc_folder_id
}

# SA для CI/CD — только push/pull
resource "yandex_iam_service_account" "registry_sa" {
  name        = "registry-pusher"
  description = "SA для CI/CD push образов"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_pusher" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.registry_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.registry_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "registry_key" {
  service_account_id = yandex_iam_service_account.registry_sa.id
  description        = "Docker auth key for CI/CD"
}
