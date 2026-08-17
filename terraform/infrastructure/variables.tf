variable "sa_key_file" {
  description = "Путь к JSON-ключу сервисного аккаунта"
  type        = string
  default     = "sa-key.json"
}

variable "yc_cloud_id" {
  type = string
}

variable "yc_folder_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "master_cores" {
  type    = number
  default = 2
}

variable "master_memory" {
  type    = number
  default = 4
}

variable "master_disk_size" {
  type    = number
  default = 30
}

variable "worker_count" {
  description = "Количество worker-нод"
  type        = number
  default     = 2
}

variable "worker_cores" {
  type    = number
  default = 2
}

variable "worker_memory" {
  type    = number
  default = 4
}

variable "worker_disk_size" {
  type    = number
  default = 30
}

variable "preemptible_workers" {
  description = "Прерываемые ВМ для worker-нод"
  type        = bool
  default     = true
}

variable "admin_cidr" {
  description = "IP для SSH доступа"
  type        = string
}
