data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

locals {
  zones = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-d",
  ]
  subnets = [
    yandex_vpc_subnet.public_a.id,
    yandex_vpc_subnet.public_b.id,
    yandex_vpc_subnet.public_d.id,
  ]
}

resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  hostname    = "k8s-master"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores         = var.master_cores
    memory        = var.master_memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.master_disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public_a.id
    nat            = true
    security_group_ids = [
      yandex_vpc_security_group.k8s_master.id,
      yandex_vpc_security_group.k8s_cluster.id,
    ]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - curl
        - wget
        - net-tools
        - python3
        - python3-pip
    EOF
  }

  scheduling_policy {
    preemptible = false
  }

  labels = {
    role = "master"
    env  = "k8s"
  }

  lifecycle {
    ignore_changes = [boot_disk]
  }
}

resource "yandex_compute_instance" "k8s_worker" {
  count       = var.worker_count
  name        = "k8s-worker-${count.index + 1}"
  hostname    = "k8s-worker-${count.index + 1}"
  zone        = local.zones[count.index % length(local.zones)]
  platform_id = "standard-v2"

  resources {
    cores         = var.worker_cores
    memory        = var.worker_memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = var.worker_disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = local.subnets[count.index % length(local.subnets)]
    nat       = true
    nat_ip_address = yandex_vpc_address.worker_ips[count.index].external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.k8s_worker.id,
      yandex_vpc_security_group.k8s_cluster.id,
    ]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - curl
        - wget
        - net-tools
        - python3
        - python3-pip
    EOF
  }

  scheduling_policy {
    preemptible = var.preemptible_workers
  }

  labels = {
    role = "worker"
    env  = "k8s"
  }

  lifecycle {
    ignore_changes = [boot_disk]
  }
}

