variable "allow_everything" {
   type = string
   default = "sg-088bbd993cbc52b59"
}
variable "ec2_instance" {
   default = {
        instance_type  = "t3.micro"
   }
}
variable "zone_id" {
    default = "Z012785114HGZTDQ8KSQH"
}
variable "domain_name" {
  default = "lithesh.shop"
}