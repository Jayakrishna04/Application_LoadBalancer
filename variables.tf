#var for vpc cidr bloc
variable "vpc-cidr" {
  default = "10.0.0.0/16"

}

# var for subnet1 cidr block
variable "subnet1-cidr" {
  default = "10.0.0.0/24"

}

# var for subnet2 cidr block
variable "subnet2-cidr" {
  default = "10.0.1.0/24"

}

# var for bucketname
variable "bucketname" {
  default = "shajaazterraformcloudchamp"

}

#var for ec2-instance
variable "ec2instance" {
  default = "ami-06aa3f7caf3a30282"

}