variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

variable "image_id" {
  description = "Boot image ID (e.g., Ubuntu 20.04)"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1" # Example Ubuntu 20.04 LTS image ID
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
