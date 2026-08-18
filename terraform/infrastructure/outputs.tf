# IP-адреса нод
output "master_external_ip" {
  value = yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address
}

output "master_internal_ip" {
  value = yandex_compute_instance.k8s_master.network_interface[0].ip_address
}

output "worker_external_ips" {
  value = [for w in yandex_compute_instance.k8s_worker : w.network_interface[0].nat_ip_address]
}

output "worker_internal_ips" {
  value = [for w in yandex_compute_instance.k8s_worker : w.network_interface[0].ip_address]
}

# Container Registry
output "registry_id" {
  value = yandex_container_registry.diploma.id
}

output "registry_endpoint" {
  description = "Используется как docker login endpoint"
  value       = "cr.yandex/${yandex_container_registry.diploma.id}"
}

# KMS
output "kms_key_id" {
  value = yandex_kms_symmetric_key.k8s_secrets_key.id
}

# Готовый inventory для Kubespray
output "kubespray_inventory" {
  description = "Автогенерация скриптом generate_inventory.sh"
  value = yamlencode({
    all = {
      hosts = merge(
        {
          "k8s-master" = {
            ansible_host = yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address
            ip           = yandex_compute_instance.k8s_master.network_interface[0].ip_address
            ansible_user = "ubuntu"
          }
        },
        {
          for i, w in yandex_compute_instance.k8s_worker :
          "k8s-worker-${i + 1}" => {
            ansible_host = w.network_interface[0].nat_ip_address
            ip           = w.network_interface[0].ip_address
            ansible_user = "ubuntu"
          }
        }
      )
      children = {
        kube_control_plane = { hosts = { "k8s-master" = {} } }
        kube_node = {
          hosts = {
            for i, w in yandex_compute_instance.k8s_worker :
            "k8s-worker-${i + 1}" => {}
          }
        }
        etcd    = { hosts = { "k8s-master" = {} } }
        k8s_cluster = {
          children = {
            kube_control_plane = {}
            kube_node          = {}
          }
        }
        calico_rr = { hosts = {} }
      }
    }
  })
}
