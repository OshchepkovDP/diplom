# Общая SG для внутреннего трафика кластера
resource "yandex_vpc_security_group" "k8s_cluster" {
  name        = "k8s-cluster-sg"
  description = "Внутренний трафик между нодами кластера"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
    description       = "Любой трафик внутри кластера"
  }

  ingress {
    protocol       = "TCP"
    port           = 30080
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "NodePort Ingress HTTP"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Весь исходящий трафик"
  }
}

# Master SG — только внешний доступ
resource "yandex_vpc_security_group" "k8s_master" {
  name       = "k8s-master-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
    description    = "SSH доступ"
  }

  ingress {
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Kubernetes API server"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Весь исходящий трафик"
  }
}

# Worker SG — только внешний доступ
resource "yandex_vpc_security_group" "k8s_worker" {
  name       = "k8s-worker-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
    description    = "SSH"
  }

  ingress {
    protocol       = "TCP"
    port           = 30080
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "NodePort Ingress HTTP"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Весь исходящий трафик"
  }
}
