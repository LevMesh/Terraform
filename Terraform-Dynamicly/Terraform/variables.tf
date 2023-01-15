variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami_id" {
    type = string
    default = "ami-097a2df4ac947655f"
}

variable "app_1_name" {
    type = string
    default = "app1"
}

variable "app_2_name" {
    type = string
    default = "app2"  
}

variable "associate_public_ip_address" {
    type = bool
    default = true
}   



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~TAGS VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



variable "instance_name_tag" {
    type = string
    default = "Lev"
  
}

variable "created_by" {
    type = string
    default = "Terraform" ///Always stays Terraform!
}

variable "creation_date" {
    type = string
    default = "20/11/2022"
}

variable "expiration_date" {
    type = string
    default = "30/11/2022"
}

variable "bootcamp" {
    type = string
    default = "16"
}







