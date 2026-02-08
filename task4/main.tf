terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  # token is usually passed via environment variable YC_TOKEN or via yc config
}

# Network
resource "yandex_vpc_network" "future_net" {
  name = "future-network"
}

# Subnet
resource "yandex_vpc_subnet" "future_subnet" {
  name           = "future-subnet-a"
  zone           = var.zone
  network_id     = yandex_vpc_network.future_net.id
  v4_cidr_blocks = var.subnet_cidr
}

# App VM (for BI/Showcase Frontend)
resource "yandex_compute_instance" "app_vm" {
  name = "app-server-1"
  zone = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.future_subnet.id
    nat       = true # Enable NAT to access internet and be accessible
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}

# DB VM (for ClickHouse)
resource "yandex_compute_instance" "db_vm" {
  name = "db-server-1"
  zone = var.zone

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 30
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.db_data_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.future_subnet.id
    nat       = false # Internal DB, access via App VM or VPN
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}

# Separate Data Disk for DB
resource "yandex_compute_disk" "db_data_disk" {
  name = "db-data-disk"
  type = "network-hdd"
  zone = var.zone
  size = 100 # 100 GB for data
}
