terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.87.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "SA для управления инфраструктурой через Terraform"
  folder_id   = var.yc_folder_id
}

locals {
  terraform_sa_roles = [
    "compute.editor",
    "vpc.admin",
    "container-registry.admin",
    "kms.admin",
    "iam.admin",
    "storage.editor",
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_sa_roles" {
  for_each  = toset(local.terraform_sa_roles)
  folder_id = var.yc_folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_iam_service_account_key" "terraform_sa_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Key for Terraform"
  key_algorithm      = "RSA_4096"
}

resource "yandex_iam_service_account_static_access_key" "terraform_s3_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Static key for S3 backend"
}

resource "yandex_storage_bucket" "tfstate" {
  access_key = yandex_iam_service_account_static_access_key.terraform_s3_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_s3_key.secret_key
  bucket     = "tfstate-${var.yc_folder_id}"

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
}

resource "local_file" "sa_key_file" {
  content = jsonencode({
    id                 = yandex_iam_service_account_key.terraform_sa_key.id
    service_account_id = yandex_iam_service_account.terraform_sa.id
    created_at         = yandex_iam_service_account_key.terraform_sa_key.created_at
    key_algorithm      = "RSA_4096"
    private_key        = yandex_iam_service_account_key.terraform_sa_key.private_key
    public_key         = yandex_iam_service_account_key.terraform_sa_key.public_key
  })
  filename        = "${path.module}/../../sa-key.json"
  file_permission = "0600"
}
