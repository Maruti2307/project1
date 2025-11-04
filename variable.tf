variable "aws_region" {
  default = "ap-south-1"
}

variable "project" {
  default = "scalable-webapp"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}

variable "db_name" {
  default = "webappdb"
}

variable "db_user" {
  default = "dbadmin"
}

variable "db_pass" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
