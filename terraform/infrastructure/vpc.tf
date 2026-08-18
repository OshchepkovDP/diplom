resource "yandex_vpc_network" "main" {
  name = "k8s-network"
}

resource "yandex_vpc_address" "worker_ips" {
  count = var.worker_count
  name  = "worker-${count.index + 1}-static-ip"
  external_ipv4_address {
    zone_id = local.zones[count.index % length(local.zones)]
  }
}

# Подсети в трёх зонах для отказоустойчивости
resource "yandex_vpc_subnet" "public_a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "public_d" {
  name           = "public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}
