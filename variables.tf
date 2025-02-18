# variables.tf

variable "aws_access_key" {
  description = "The IAM public access key"
}

variable "aws_secret_key" {
  description = "IAM secret access key"
}

variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = ""
}

variable "app_image_frontend" {
  description = "Docker image to run in the ECS cluster"
  default     = ""
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "app_port_frontend" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "app_count_frontend" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/health"
}

variable "health_check_path_frontend" {
  default = "/health"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "fargate_memory_frontend" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "3072"
}

variable "fargate_cpu_api" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory_api" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "environment" {
  description = "The environment for the application (e.g., 'development', 'production')"
  type        = string
}

variable "aws_account_id" {
  default = 1
}

variable "frontend_domain" {
  default = "frontend.com"
}

variable "public_frontend_domain" {
  default = "*.frontend.com"
}

variable "api_domain" {
  default = "api.com"
}