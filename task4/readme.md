# Задание 4. Проектирование облачной инфраструктуры с применением IaaS и Terraform

## Состав задания
В этой директории находятся файлы решения:

1.  **Terraform конфигурация:**
    - `main.tf` - описание ресурсов (VPC, Subnet, VMs, Disks).
    - `variables.tf` - описание переменных.
    - `outputs.tf` - выходные параметры.
    - `terraform.tfvars.example` - пример значений переменных (разумеется, реальный файл я в репозиторий не положил).
    - `justification.md` - обоснование выбора конфигурации.
    - `terraform.rc` - конфигурация зеркала провайдеров (для решения проблем с доступом к registry.terraform.io).

2.  **Диаграмма:**

    ![Deployment Automation Diagram](diagram.png)

## Как запустить

Для запуска Terraform через Docker выполните следующие команды (находясь в директории `task4`):

**Важно:** Если вы находитесь в РФ или испытываете проблемы с доступом к `registry.terraform.io` (ошибка `Invalid provider registry host`), используйте флаг `-e TF_CLI_CONFIG_FILE=/workspace/terraform.rc` во всех командах.

1.  **Инициализация:**
    ```bash
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc hashicorp/terraform:latest init
    ```

    Пример вывода:

    ```
    $ docker run --rm -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -v .:/workspace -w /workspace hashicorp/terraform:latest init 
    Initializing the backend...                                                                                                   
    Initializing provider plugins...                                                                                              
    - Finding latest version of yandex-cloud/yandex...                                                                            
    - Installing yandex-cloud/yandex v0.184.0...                                                                                  
    - Installed yandex-cloud/yandex v0.184.0 (unauthenticated)                                                                    
    Terraform has created a lock file .terraform.lock.hcl to record the provider                                                  
    selections it made above. Include this file in your version control repository                                                
    so that Terraform can guarantee to make the same selections by default when                                                   
    you run "terraform init" in the future.                                                                                       
                                                                                                                                
    ╷                                                                                                                             
    │ Warning: Incomplete lock file information for providers                                                                     
    │                                                                                                                             
    │ Due to your customized provider installation methods, Terraform was forced                                                  
    │ to calculate lock file checksums locally for the following providers:                                                       
    │   - yandex-cloud/yandex                                                                                                     
    │                                                                                                                             
    │ The current .terraform.lock.hcl file only includes checksums for                                                            
    │ linux_amd64, so Terraform running on another platform will fail to install                                                  
    │ these providers.                                                                                                            
    │                                                                                                                             
    │ To calculate additional checksums for another platform, run:                                                                
    │   terraform providers lock -platform=linux_amd64                                                                            
    │ (where linux_amd64 is the platform to generate)                                                                             
    ╵                                                                                                                             
    Terraform has been successfully initialized!                                                                                  
                                                                                                                                
    You may now begin working with Terraform. Try running "terraform plan" to see                                                 
    any changes that are required for your infrastructure. All Terraform commands                                                 
    should now work.                                                                                                              
                                                                                                                                
    If you ever set or change modules or backend configuration for Terraform,                                                     
    rerun this command to reinitialize your working directory. If you forget, other                                               
    commands will detect it and remind you to do so if necessary.                                                                 
    ```

2.  **Валидация конфигурации:**
    ```bash
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc hashicorp/terraform:latest validate
    ```

    Пример вывода:

    ```
    $ docker run --rm -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc hashicorp/terraform:latest validate 
    Success! The configuration is valid.                                                                                                                          
    ```

3.  **Планирование (требуется токен Yandex Cloud):**
    Необходимо передать токен через переменную окружения `YC_TOKEN`.
    ```bash
    # Windows (PowerShell)
    $env:YC_TOKEN = (yc iam create-token)
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=$env:YC_TOKEN hashicorp/terraform:latest plan

    # Linux/macOS/Git Bash
    export YC_TOKEN=$(yc iam create-token)
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=$YC_TOKEN hashicorp/terraform:latest plan
    ```

    Пример вывода:

    ```
    $ docker run --rm -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=%YC_TO
    KEN% hashicorp/terraform:latest plan                                                                                                                         
                                                                                                                                                                
    Terraform used the selected providers to generate the following execution                                                                                    
    plan. Resource actions are indicated with the following symbols:                                                                                             
    + create                                                                                                                                                   
                                                                                                                                                                
    Terraform will perform the following actions:                                                                                                                
                                                                                                                                                                
    # yandex_compute_disk.db_data_disk will be created                                                                                                         
    + resource "yandex_compute_disk" "db_data_disk" {                                                                                                          
        + block_size  = 4096                                                                                                                                   
        + created_at  = (known after apply)                                                                                                                    
        + folder_id   = (known after apply)                                                                                                                    
        + id          = (known after apply)                                                                                                                    
        + name        = "db-data-disk"                                                                                                                         
        + product_ids = (known after apply)                                                                                                                    
        + size        = 100                                                                                                                                    
        + status      = (known after apply)                                                                                                                    
        + type        = "network-hdd"                                                                                                                          
        + zone        = "ru-central1-a"                                                                                                                        
                                                                                                                                                                
        + disk_placement_policy (known after apply)                                                                                                            
                                                                                                                                                                
        + hardware_generation (known after apply)                                                                                                              
        }                                                                                                                                                        
                                                                                                                                                                
    # yandex_compute_instance.app_vm will be created                                                                                                           
    + resource "yandex_compute_instance" "app_vm" {                                                                                                            
        + created_at                = (known after apply)                                                                                                      
        + folder_id                 = (known after apply)                                                                                                      
        + fqdn                      = (known after apply)                                                                                                      
        + gpu_cluster_id            = (known after apply)                                                                                                      
        + hardware_generation       = (known after apply)                                                                                                      
        + hostname                  = (known after apply)                                                                                                      
        + id                        = (known after apply)                                                                                                      
        + maintenance_grace_period  = (known after apply)                                                                                                      
        + maintenance_policy        = (known after apply)                                                                                                      
        + metadata                  = {                                                                                                                        
            + "ssh-keys" = <<-EOT                                                                                                                              
                    ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...dummy...key... wolde@cursor                                                                 
                EOT                                                                                                                                              
            }                                                                                                                                                    
        + name                      = "app-server-1"                                                                                                           
        + network_acceleration_type = "standard"                                                                                                               
        + platform_id               = "standard-v1"                                                                                                            
        + status                    = (known after apply)                                                                                                      
        + zone                      = "ru-central1-a"                                                                                                          
                                                                                                                                                                
        + boot_disk {                                                                                                                                          
            + auto_delete = true                                                                                                                               
            + device_name = (known after apply)                                                                                                                
            + disk_id     = (known after apply)                                                                                                                
            + mode        = (known after apply)                                                                                                                
                                                                                                                                                                
            + initialize_params {                                                                                                                              
                + block_size  = (known after apply)                                                                                                            
                + description = (known after apply)                                                                                                            
                + image_id    = "fd80mrhj8fl2oe87o4e1"                                                                                                         
                + name        = (known after apply)                                                                                                            
                + size        = 20                                                                                                                             
                + snapshot_id = (known after apply)                                                                                                            
                + type        = "network-hdd"                                                                                                                  
                }                                                                                                                                                
            }                                                                                                                                                    
                                                                                                                                                                
        + metadata_options (known after apply)                                                                                                                 
                                                                                                                                                                
        + network_interface {                                                                                                                                  
            + index          = (known after apply)                                                                                                             
            + ip_address     = (known after apply)                                                                                                             
            + ipv4           = true                                                                                                                            
            + ipv6           = (known after apply)                                                                                                             
            + ipv6_address   = (known after apply)                                                                                                             
            + mac_address    = (known after apply)                                                                                                             
            + nat            = true                                                                                                                            
            + nat_ip_address = (known after apply)                                                                                                             
            + nat_ip_version = (known after apply)                                                                                                             
            + subnet_id      = (known after apply)                                                                                                             
            }                                                                                                                                                    
                                                                                                                                                                
        + placement_policy (known after apply)                                                                                                                 
                                                                                                                                                                
        + resources {                                                                                                                                          
            + core_fraction = 100                                                                                                                              
            + cores         = 2                                                                                                                                
            + memory        = 4                                                                                                                                
            }                                                                                                                                                    
                                                                                                                                                                
        + scheduling_policy (known after apply)                                                                                                                
        }                                                                                                                                                        
                                                                                                                                                                
    # yandex_compute_instance.db_vm will be created                                                                                                            
    + resource "yandex_compute_instance" "db_vm" {                                                                                                             
        + created_at                = (known after apply)                                                                                                      
        + folder_id                 = (known after apply)                                                                                                      
        + fqdn                      = (known after apply)                                                                                                      
        + gpu_cluster_id            = (known after apply)                                                                                                      
        + hardware_generation       = (known after apply)                                                                                                      
        + hostname                  = (known after apply)                                                                                                      
        + id                        = (known after apply)                                                                                                      
        + maintenance_grace_period  = (known after apply)                                                                                                      
        + maintenance_policy        = (known after apply)                                                                                                      
        + metadata                  = {                                                                                                                        
            + "ssh-keys" = <<-EOT                                                                                                                              
                    ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...dummy...key... wolde@cursor                                                                 
                EOT                                                                                                                                              
            }                                                                                                                                                    
        + name                      = "db-server-1"                                                                                                            
        + network_acceleration_type = "standard"                                                                                                               
        + platform_id               = "standard-v1"                                                                                                            
        + status                    = (known after apply)                                                                                                      
        + zone                      = "ru-central1-a"                                                                                                          
                                                                                                                                                                
        + boot_disk {                                                                                                                                          
            + auto_delete = true                                                                                                                               
            + device_name = (known after apply)                                                                                                                
            + disk_id     = (known after apply)                                                                                                                
            + mode        = (known after apply)                                                                                                                
                                                                                                                                                                
            + initialize_params {                                                                                                                              
                + block_size  = (known after apply)                                                                                                            
                + description = (known after apply)                                                                                                            
                + image_id    = "fd80mrhj8fl2oe87o4e1"                                                                                                         
                + name        = (known after apply)                                                                                                            
                + size        = 30                                                                                                                             
                + snapshot_id = (known after apply)                                                                                                            
                + type        = "network-hdd"                                                                                                                  
                }                                                                                                                                                
            }                                                                                                                                                    
                                                                                                                                                                
        + metadata_options (known after apply)                                                                                                                 
                                                                                                                                                                
        + network_interface {                                                                                                                                  
            + index          = (known after apply)                                                                                                             
            + ip_address     = (known after apply)                                                                                                             
            + ipv4           = true                                                                                                                            
            + ipv6           = (known after apply)                                                                                                             
            + ipv6_address   = (known after apply)                                                                                                             
            + mac_address    = (known after apply)                                                                                                             
            + nat            = false                                                                                                                           
            + nat_ip_address = (known after apply)                                                                                                             
            + nat_ip_version = (known after apply)                                                                                                             
            + subnet_id      = (known after apply)                                                                                                             
            }                                                                                                                                                    
                                                                                                                                                                
        + placement_policy (known after apply)                                                                                                                 
                                                                                                                                                                
        + resources {                                                                                                                                          
            + core_fraction = 100                                                                                                                              
            + cores         = 4                                                                                                                                
            + memory        = 8                                                                                                                                
            }                                                                                                                                                    
                                                                                                                                                                
        + scheduling_policy (known after apply)                                                                                                                
                                                                                                                                                                
        + secondary_disk {                                                                                                                                     
            + auto_delete = false                                                                                                                              
            + device_name = (known after apply)                                                                                                                
            + disk_id     = (known after apply)                                                                                                                
            + mode        = "READ_WRITE"                                                                                                                       
            }                                                                                                                                                    
        }                                                                                                                                                        
                                                                                                                                                                
    # yandex_vpc_network.future_net will be created                                                                                                            
    + resource "yandex_vpc_network" "future_net" {                                                                                                             
        + created_at                = (known after apply)                                                                                                      
        + default_security_group_id = (known after apply)                                                                                                      
        + folder_id                 = (known after apply)                                                                                                      
        + id                        = (known after apply)                                                                                                      
        + labels                    = (known after apply)                                                                                                      
        + name                      = "future-network"                                                                                                         
        + subnet_ids                = (known after apply)                                                                                                      
        }                                                                                                                                                        
                                                                                                                                                                
    # yandex_vpc_subnet.future_subnet will be created                                                                                                          
    + resource "yandex_vpc_subnet" "future_subnet" {                                                                                                           
        + created_at     = (known after apply)                                                                                                                 
        + folder_id      = (known after apply)                                                                                                                 
        + id             = (known after apply)                                                                                                                 
        + labels         = (known after apply)                                                                                                                 
        + name           = "future-subnet-a"                                                                                                                   
        + network_id     = (known after apply)                                                                                                                 
        + v4_cidr_blocks = [                                                                                                                                   
            + "192.168.10.0/24",                                                                                                                               
            ]                                                                                                                                                    
        + v6_cidr_blocks = (known after apply)                                                                                                                 
        + zone           = "ru-central1-a"                                                                                                                     
        }                                                                                                                                                        
                                                                                                                                                                
    Plan: 5 to add, 0 to change, 0 to destroy.                                                                                                                   
                                                                                                                                                                
    Changes to Outputs:                                                                                                                                          
    + app_external_ip = (known after apply)                                                                                                                    
    + app_internal_ip = (known after apply)                                                                                                                    
    + db_internal_ip  = (known after apply)                                                                                                                    
                                                                                                                                                                
    ─────────────────────────────────────────────────────────────────────────────                                                                                
                                                                                                                                                                
    Note: You didn't use the -out option to save this plan, so Terraform can't                                                                                   
    guarantee to take exactly these actions if you run "terraform apply" now.                                                                                    
    ```

4.  **Применение:**
    ```bash
    # Windows (PowerShell)
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=$env:YC_TOKEN hashicorp/terraform:latest apply -auto-approve

    # Linux/macOS/Git Bash
    docker run --rm -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=$YC_TOKEN hashicorp/terraform:latest apply -auto-approve
    ```

    Пример вывода:

    ```
    $ docker run --rm -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -v .:/workspace -w /workspace -e TF_CLI_CONFIG_FILE=/workspace/terraform.rc -e YC_TOKEN=%YC_TOKEN% hashicorp/terraform:latest apply -auto-approve            
                                                                                                                                                                                                                                
    Terraform used the selected providers to generate the following execution                                                                                                                                                    
    plan. Resource actions are indicated with the following symbols:                                                                                                                                                             
    + create                                                                                                                                                                                                                   
                                                                                                                                                                                                                                
    Terraform will perform the following actions:                                                                                                                                                                                
                                                                                                                                                                                                                                
    # yandex_compute_disk.db_data_disk will be created                                                                                                                                                                         
    + resource "yandex_compute_disk" "db_data_disk" {                                                                                                                                                                          
        + block_size  = 4096                                                                                                                                                                                                   
        + created_at  = (known after apply)                                                                                                                                                                                    
        + folder_id   = (known after apply)                                                                                                                                                                                    
        + id          = (known after apply)                                                                                                                                                                                    
        + name        = "db-data-disk"                                                                                                                                                                                         
        + product_ids = (known after apply)                                                                                                                                                                                    
        + size        = 100                                                                                                                                                                                                    
        + status      = (known after apply)                                                                                                                                                                                    
        + type        = "network-hdd"                                                                                                                                                                                          
        + zone        = "ru-central1-a"                                                                                                                                                                                        
                                                                                                                                                                                                                                
        + disk_placement_policy (known after apply)                                                                                                                                                                            
                                                                                                                                                                                                                                
        + hardware_generation (known after apply)                                                                                                                                                                              
        }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                
    # yandex_compute_instance.app_vm will be created                                                                                                                                                                           
    + resource "yandex_compute_instance" "app_vm" {                                                                                                                                                                            
        + created_at                = (known after apply)                                                                                                                                                                      
        + folder_id                 = (known after apply)                                                                                                                                                                      
        + fqdn                      = (known after apply)                                                                                                                                                                      
        + gpu_cluster_id            = (known after apply)                                                                                                                                                                      
        + hardware_generation       = (known after apply)                                                                                                                                                                      
        + hostname                  = (known after apply)                                                                                                                                                                      
        + id                        = (known after apply)                                                                                                                                                                      
        + maintenance_grace_period  = (known after apply)                                                                                                                                                                      
        + maintenance_policy        = (known after apply)                                                                                                                                                                      
        + metadata                  = {                                                                                                                                                                                        
            + "ssh-keys" = <<-EOT                                                                                                                                                                                              
                    ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...dummy...key... wolde@cursor                                                                                                                                 
                EOT                                                                                                                                                                                                              
            }                                                                                                                                                                                                                    
        + name                      = "app-server-1"                                                                                                                                                                           
        + network_acceleration_type = "standard"                                                                                                                                                                               
        + platform_id               = "standard-v1"                                                                                                                                                                            
        + status                    = (known after apply)                                                                                                                                                                      
        + zone                      = "ru-central1-a"                                                                                                                                                                          
                                                                                                                                                                                                                                
        + boot_disk {                                                                                                                                                                                                          
            + auto_delete = true                                                                                                                                                                                               
            + device_name = (known after apply)                                                                                                                                                                                
            + disk_id     = (known after apply)                                                                                                                                                                                
            + mode        = (known after apply)                                                                                                                                                                                
                                                                                                                                                                                                                                
            + initialize_params {                                                                                                                                                                                              
                + block_size  = (known after apply)                                                                                                                                                                            
                + description = (known after apply)                                                                                                                                                                            
                + image_id    = "fd80mrhj8fl2oe87o4e1"                                                                                                                                                                         
                + name        = (known after apply)                                                                                                                                                                            
                + size        = 20                                                                                                                                                                                             
                + snapshot_id = (known after apply)                                                                                                                                                                            
                + type        = "network-hdd"                                                                                                                                                                                  
                }                                                                                                                                                                                                                
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + metadata_options (known after apply)                                                                                                                                                                                 
                                                                                                                                                                                                                                
        + network_interface {                                                                                                                                                                                                  
            + index          = (known after apply)                                                                                                                                                                             
            + ip_address     = (known after apply)                                                                                                                                                                             
            + ipv4           = true                                                                                                                                                                                            
            + ipv6           = (known after apply)                                                                                                                                                                             
            + ipv6_address   = (known after apply)                                                                                                                                                                             
            + mac_address    = (known after apply)                                                                                                                                                                             
            + nat            = true                                                                                                                                                                                            
            + nat_ip_address = (known after apply)                                                                                                                                                                             
            + nat_ip_version = (known after apply)                                                                                                                                                                             
            + subnet_id      = (known after apply)                                                                                                                                                                             
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + placement_policy (known after apply)                                                                                                                                                                                 
                                                                                                                                                                                                                                
        + resources {                                                                                                                                                                                                          
            + core_fraction = 100                                                                                                                                                                                              
            + cores         = 2                                                                                                                                                                                                
            + memory        = 4                                                                                                                                                                                                
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + scheduling_policy (known after apply)                                                                                                                                                                                
        }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                
    # yandex_compute_instance.db_vm will be created                                                                                                                                                                            
    + resource "yandex_compute_instance" "db_vm" {                                                                                                                                                                             
        + created_at                = (known after apply)                                                                                                                                                                      
        + folder_id                 = (known after apply)                                                                                                                                                                      
        + fqdn                      = (known after apply)                                                                                                                                                                      
        + gpu_cluster_id            = (known after apply)                                                                                                                                                                      
        + hardware_generation       = (known after apply)                                                                                                                                                                      
        + hostname                  = (known after apply)                                                                                                                                                                      
        + id                        = (known after apply)                                                                                                                                                                      
        + maintenance_grace_period  = (known after apply)                                                                                                                                                                      
        + maintenance_policy        = (known after apply)                                                                                                                                                                      
        + metadata                  = {                                                                                                                                                                                        
            + "ssh-keys" = <<-EOT                                                                                                                                                                                              
                    ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...dummy...key... wolde@cursor                                                                                                                                 
                EOT                                                                                                                                                                                                              
            }                                                                                                                                                                                                                    
        + name                      = "db-server-1"                                                                                                                                                                            
        + network_acceleration_type = "standard"                                                                                                                                                                               
        + platform_id               = "standard-v1"                                                                                                                                                                            
        + status                    = (known after apply)                                                                                                                                                                      
        + zone                      = "ru-central1-a"                                                                                                                                                                          
                                                                                                                                                                                                                                
        + boot_disk {                                                                                                                                                                                                          
            + auto_delete = true                                                                                                                                                                                               
            + device_name = (known after apply)                                                                                                                                                                                
            + disk_id     = (known after apply)                                                                                                                                                                                
            + mode        = (known after apply)                                                                                                                                                                                
                                                                                                                                                                                                                                
            + initialize_params {                                                                                                                                                                                              
                + block_size  = (known after apply)                                                                                                                                                                            
                + description = (known after apply)                                                                                                                                                                            
                + image_id    = "fd80mrhj8fl2oe87o4e1"                                                                                                                                                                         
                + name        = (known after apply)                                                                                                                                                                            
                + size        = 30                                                                                                                                                                                             
                + snapshot_id = (known after apply)                                                                                                                                                                            
                + type        = "network-hdd"                                                                                                                                                                                  
                }                                                                                                                                                                                                                
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + metadata_options (known after apply)                                                                                                                                                                                 
                                                                                                                                                                                                                                
        + network_interface {                                                                                                                                                                                                  
            + index          = (known after apply)                                                                                                                                                                             
            + ip_address     = (known after apply)                                                                                                                                                                             
            + ipv4           = true                                                                                                                                                                                            
            + ipv6           = (known after apply)                                                                                                                                                                             
            + ipv6_address   = (known after apply)                                                                                                                                                                             
            + mac_address    = (known after apply)                                                                                                                                                                             
            + nat            = false                                                                                                                                                                                           
            + nat_ip_address = (known after apply)                                                                                                                                                                             
            + nat_ip_version = (known after apply)                                                                                                                                                                             
            + subnet_id      = (known after apply)                                                                                                                                                                             
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + placement_policy (known after apply)                                                                                                                                                                                 
                                                                                                                                                                                                                                
        + resources {                                                                                                                                                                                                          
            + core_fraction = 100                                                                                                                                                                                              
            + cores         = 4                                                                                                                                                                                                
            + memory        = 8                                                                                                                                                                                                
            }                                                                                                                                                                                                                    
                                                                                                                                                                                                                                
        + scheduling_policy (known after apply)                                                                                                                                                                                
                                                                                                                                                                                                                                
        + secondary_disk {                                                                                                                                                                                                     
            + auto_delete = false                                                                                                                                                                                              
            + device_name = (known after apply)                                                                                                                                                                                
            + disk_id     = (known after apply)                                                                                                                                                                                
            + mode        = "READ_WRITE"                                                                                                                                                                                       
            }                                                                                                                                                                                                                    
        }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                
    # yandex_vpc_network.future_net will be created                                                                                                                                                                            
    + resource "yandex_vpc_network" "future_net" {                                                                                                                                                                             
        + created_at                = (known after apply)                                                                                                                                                                      
        + default_security_group_id = (known after apply)                                                                                                                                                                      
        + folder_id                 = (known after apply)                                                                                                                                                                      
        + id                        = (known after apply)                                                                                                                                                                      
        + labels                    = (known after apply)                                                                                                                                                                      
        + name                      = "future-network"                                                                                                                                                                         
        + subnet_ids                = (known after apply)                                                                                                                                                                      
        }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                
    # yandex_vpc_subnet.future_subnet will be created                                                                                                                                                                          
    + resource "yandex_vpc_subnet" "future_subnet" {                                                                                                                                                                           
        + created_at     = (known after apply)                                                                                                                                                                                 
        + folder_id      = (known after apply)                                                                                                                                                                                 
        + id             = (known after apply)                                                                                                                                                                                 
        + labels         = (known after apply)                                                                                                                                                                                 
        + name           = "future-subnet-a"                                                                                                                                                                                   
        + network_id     = (known after apply)                                                                                                                                                                                 
        + v4_cidr_blocks = [                                                                                                                                                                                                   
            + "192.168.10.0/24",                                                                                                                                                                                               
            ]                                                                                                                                                                                                                    
        + v6_cidr_blocks = (known after apply)                                                                                                                                                                                 
        + zone           = "ru-central1-a"                                                                                                                                                                                     
        }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                
    Plan: 5 to add, 0 to change, 0 to destroy.                                                                                                                                                                                   
                                                                                                                                                                                                                                
    Changes to Outputs:                                                                                                                                                                                                          
    + app_external_ip = (known after apply)                                                                                                                                                                                    
    + app_internal_ip = (known after apply)                                                                                                                                                                                    
    + db_internal_ip  = (known after apply)                                                                                                                                                                                    
    yandex_vpc_network.future_net: Creating...                                                                                                                                                                                   
    yandex_compute_disk.db_data_disk: Creating...                                                                                                                                                                                
    yandex_vpc_network.future_net: Creation complete after 2s [id=enpcg2f88fdmno8rm9sh]                                                                                                                                          
    yandex_vpc_subnet.future_subnet: Creating...                                                                                                                                                                                 
    yandex_vpc_subnet.future_subnet: Creation complete after 1s [id=e9bkdcjljorod2enru94]                                                                                                                                        
    yandex_compute_instance.app_vm: Creating...                                                                                                                                                                                  
    yandex_compute_disk.db_data_disk: Creation complete after 10s [id=fhmuc0da61b9v3i4n28u]                                                                                                                                      
    yandex_compute_instance.db_vm: Creating...                                                                                                                                                                                   
    yandex_compute_instance.app_vm: Still creating... [00m10s elapsed]                                                                                                                                                           
    yandex_compute_instance.db_vm: Still creating... [00m10s elapsed]                                                                                                                                                            
    yandex_compute_instance.app_vm: Still creating... [00m20s elapsed]                                                                                                                                                           
    yandex_compute_instance.db_vm: Still creating... [00m20s elapsed]                                                                                                                                                            
    yandex_compute_instance.app_vm: Still creating... [00m30s elapsed]                                                                                                                                                           
    yandex_compute_instance.db_vm: Still creating... [00m30s elapsed]                                                                                                                                                            
    yandex_compute_instance.app_vm: Still creating... [00m40s elapsed]                                                                                                                                                           
    yandex_compute_instance.db_vm: Creation complete after 35s [id=fhm57vr92vsbq98tnl20]                                                                                                                                         
    yandex_compute_instance.app_vm: Still creating... [00m50s elapsed]                                                                                                                                                           
    yandex_compute_instance.app_vm: Creation complete after 51s [id=fhmeu92o8a5qmm66usf8]                                                                                                                                        
                                                                                                                                                                                                                                
    Apply complete! Resources: 5 added, 0 changed, 0 destroyed.                                                                                                                                                                  
                                                                                                                                                                                                                                
    Outputs:                                                                                                                                                                                                                     
                                                                                                                                                                                                                                
    app_external_ip = "51.250.67.132"                                                                                                                                                                                            
    app_internal_ip = "192.168.10.30"                                                                                                                                                                                            
    db_internal_ip = "192.168.10.16"                                                                                                                                                                                             
    ```

## Описание инфраструктуры

Разворачивается сегмент инфраструктуры для "Витрины данных":
*   **Сеть:** `future-network`
*   **Подсеть:** `future-subnet-a` (192.168.10.0/24)
*   **App Server:** VM (2 vCPU, 4GB RAM) с публичным IP для хостинга BI-системы.
*   **DB Server:** VM (4 vCPU, 8GB RAM) с дополнительным диском 100GB для ClickHouse. Доступ только внутри сети.

Подробное обоснование см. в файле `justification.md`.
