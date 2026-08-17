output "bucket_name" {
  value = yandex_storage_bucket.tfstate.bucket
}

output "terraform_sa_id" {
  value = yandex_iam_service_account.terraform_sa.id
}

output "s3_access_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_s3_key.access_key
  sensitive = true
}

output "s3_secret_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_s3_key.secret_key
  sensitive = true
}

output "next_steps" {
  value = <<-EOT
    После применения выполни:
    
    1. Забери ключи S3:
       terraform output -raw s3_access_key
       terraform output -raw s3_secret_key
    
    2. Добавь в GitHub Secrets:
       TF_S3_ACCESS_KEY = (из п.1)
       TF_S3_SECRET_KEY = (из п.1)
       TF_STATE_BUCKET  = ${yandex_storage_bucket.tfstate.bucket}
    
    3. SA ключ сохранён в: ../../sa-key.json
  EOT
}
