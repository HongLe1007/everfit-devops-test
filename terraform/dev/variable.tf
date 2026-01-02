variable "acm_certificate_arn" {
  description = "ARN of the ACM SSL certificate"
  type        = string
  default     = ""
}

variable "aws_lb_arn" {
  description = "AWS ALB Arn"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region to deploy application"
  default     = "us-west-2"
}

variable "aws_vpc_id" {
  description = "AWS VPC ID"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "ECR image URI with tag"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name (e.g., sample-app.example.com)"
  type        = string
  default     = "sample-app.example.com"
}

variable "private_subnet_ecs" {
  description = "A list of subnets which ECS tasks will use"
  type        = list(string)
  default     = []
}

variable "security_groups_alb_id" {
  description = "Security groups ID which associated with ALB "
  type        = string
  default     = ""
}

variable "security_groups_ecs_id" {
  description = "Security groups to associate with ECS tasks"
  type        = string
  default     = ""
}

variable "iam_ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  type        = string
  default     = ""
}

variable "iam_ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
  default     = ""
}