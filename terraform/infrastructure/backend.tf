terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    key    = "infrastructure/terraform.tfstate"
    region = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
