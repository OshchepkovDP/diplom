# KMS-ключ для шифрования secrets в K8s
resource "yandex_kms_symmetric_key" "k8s_secrets_key" {
  name              = "k8s-secrets-key"
  description       = "Encrypts Kubernetes secrets at rest"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}
