terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  # Токен будет задан через переменную окружения GITHUB_TOKEN
  # или через переменную var.github_token в terraform.tfvars
}

# Основной репозиторий
resource "github_repository" "devops_lab_repo" {
  name        = "devops-lab-7-1"
  description = "Репозиторий для практической работы по DevOps (IaC с Terraform)"
  visibility  = "public"
  
  # Настройки из задания
  has_issues         = true
  has_wiki           = true
  has_projects       = false
  has_downloads      = true
  auto_init          = true
  
  # Настройки слияния
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
  delete_branch_on_merge = true
  
  # Ветка по умолчанию
  default_branch = "main"
  
  # Лицензия (опционально)
  license_template = "mit"
  
  # Архивация при удалении через terraform destroy
  archive_on_destroy = true
}

# Защита основной ветки
resource "github_branch_protection" "main" {
  repository_id = github_repository.devops_lab_repo.node_id
  pattern       = "main"
  
  # Базовые настройки защиты
  allows_deletions              = false
  allows_force_pushes           = false
  enforce_admins                = false
  
  # Требования к пулл-реквестам
  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
  }
  
  # Проверки статуса (можно добавить позже)
  required_status_checks {
    strict   = false
    contexts = []
  }
}

# Создание файла README.md в репозитории
resource "github_repository_file" "readme" {
  repository          = github_repository.devops_lab_repo.name
  branch              = "main"
  file                = "README.md"
  content             = <<-EOT
    # Практическая работа №7.1
    ## Инфраструктура в виде кода (IaC) с Terraform
    
    Этот репозиторий создан автоматически с помощью Terraform в рамках практической работы.
    
    ### Цель работы
    Освоение принципов Infrastructure as Code с использованием Terraform для управления ресурсами GitHub.
    
    ### Созданные ресурсы:
    1. Публичный репозиторий
    2. Защита ветки main
    3. Файл README.md
    4. Файл конфигурации Terraform
    
    ### Автор
    Студент: [Ваше ФИО]
    Группа: [Ваша группа]
    Преподаватель: Гиматдинов Дамир Маратович
  EOT
  commit_message      = "Добавлен README.md через Terraform"
  commit_author       = "Terraform Bot"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Копирование конфигурации Terraform в сам репозиторий
resource "github_repository_file" "terraform_config" {
  repository          = github_repository.devops_lab_repo.name
  branch              = "main"
  file                = "terraform/main.tf"
  content             = file("${path.module}/main.tf")
  commit_message      = "Добавлена конфигурация Terraform"
  commit_author       = "Terraform Bot"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Webhook для уведомлений (опционально, по требованию задания)
resource "github_repository_webhook" "example" {
  repository = github_repository.devops_lab_repo.name
  
  configuration {
    url          = "https://example.com/webhook"
    content_type = "json"
    insecure_ssl = false
  }
  
  events = ["push", "pull_request"]
  active = true
}

# Выводы для удобства
output "repository_url" {
  value = github_repository.devops_lab_repo.html_url
}

output "ssh_clone_url" {
  value = github_repository.devops_lab_repo.ssh_clone_url
}

output "repository_name" {
  value = github_repository.devops_lab_repo.full_name
}