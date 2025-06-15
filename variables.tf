variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
  default     = "vpc-066a92a2b6a0fa4d3"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "ummkey"
}

# Add new variables for flexibility
variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = ["subnet-0bdc4fd39f9ebfef1", "subnet-03c889316d8dfd2f9"]
}

variable "bi_subnet_id" {
  description = "Subnet ID for BI instance"
  type        = string
  default     = "subnet-0bd554e443dec9cb5"
}
