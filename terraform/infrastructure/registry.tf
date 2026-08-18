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

resource "yandex_iam_service_account_key" "registry_key" {
  service_account_id = yandex_iam_service_account.registry_sa.id
  description        = "JSON authorized key for Docker auth in CI/CD"
  key_algorithm      = "RSA_2048"
}

output "registry_sa_json_key" {
  value = jsonencode({
    id                 = yandex_iam_service_account_key.registry_key.id
    service_account_id = yandex_iam_service_account.registry_sa.id
    created_at         = yandex_iam_service_account_key.registry_key.created_at
    key_algorithm      = "RSA_2048"
    private_key        = yandex_iam_service_account_key.registry_key.private_key
    public_key         = yandex_iam_service_account_key.registry_key.public_key
  })
  sensitive = true
}
