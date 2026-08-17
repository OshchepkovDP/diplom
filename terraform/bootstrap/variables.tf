variable "yc_token" {
  description = "Личный IAM токен (yc iam create-token)"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  type = string
}

variable "yc_folder_id" {
  type = string
}
