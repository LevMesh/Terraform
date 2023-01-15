terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"

    backend "s3" {
        bucket      = "lev-terra"
        key         = "terraform.tfstate"
        region      = "us-east-2"
    }
}

provider "aws" {
    region  = "us-east-2"
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~NETWORKING & Security Groups~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Define VPC
resource "aws_vpc" "lev-doitDynamic-vpc" {

    cidr_block = "10.5.5.0/24"
    instance_tenancy = "default"

    tags = {
        "Name"            = "lev-doitDynamic-vpc"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# Define subnet-1 in our VPC
resource "aws_subnet" "lev-doitDynamic-sub1" {

    vpc_id            = aws_vpc.lev-doitDynamic-vpc.id
    cidr_block        = "10.5.5.16/28"
    availability_zone = "us-east-2a"

    tags = {
        "Name"            = "doitDynamic-sub1"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# Define subnet-2 in our VPC
resource "aws_subnet" "lev-doitDynamic-sub2" {

    vpc_id            = aws_vpc.lev-doitDynamic-vpc.id
    cidr_block        = "10.5.5.32/28"
    availability_zone = "us-east-2b"

    tags = {
        "Name"            = "lev-doitDynamic-sub2"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date 
        "creation_date"   = var.creation_date
    }
}

# Define our IGW
resource "aws_internet_gateway" "lev-doitDynamic-IGW" {
    vpc_id = aws_vpc.lev-doitDynamic-vpc.id

    tags = {
        "Name"            = "lev-doitDynamic-IGW"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# Define our Route-Table
resource "aws_route_table" "lev-doitDynamic-RT" {
    vpc_id = aws_vpc.lev-doitDynamic-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lev-doitDynamic-IGW.id
    }

    tags = {
        "Name"            = "Lev-RT"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# associate our Route-Table & Internet-Getway 
resource "aws_main_route_table_association" "igw-rt" {
    vpc_id         = aws_vpc.lev-doitDynamic-vpc.id
    route_table_id = aws_route_table.lev-doitDynamic-RT.id
}

# Define instances security group
resource "aws_security_group" "instance" {
    name        = "app_instance_sg"
    description = "Aws sg for app instances"
    vpc_id      = aws_vpc.lev-doitDynamic-vpc.id

    ingress {
        description      = "Allow port 3000 from loadbalancer security-group"
        from_port        = 3000
        to_port          = 3000
        protocol         = "TCP"
        security_groups = [ aws_security_group.lb-sg.id ]
    }

    ingress {
        description      = "Allow ssh"
        from_port        = 22
        to_port          = 22
        protocol         = "TCP"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        "Name"            = "app_instance_sg"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# Define Load-Balancer security group
resource "aws_security_group" "lb-sg" {
    name        = "app_lb_sg"
    description = "Aws sg for app instances"
    vpc_id      = aws_vpc.lev-doitDynamic-vpc.id

    ingress {
        description      = "http from vpc"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        "Name"            = "app_lb_sg"
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~INSTANCES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Define first instance
resource "aws_instance" "lev-instance1" {
    ami                                 = var.ami_id
    instance_type                       = var.instance_type
    subnet_id                           = aws_subnet.lev-doitDynamic-sub1.id
    associate_public_ip_address         = var.associate_public_ip_address
    iam_instance_profile                = "${aws_iam_instance_profile.instance_profile.name}"
    # key_name = [""]#TODO
    vpc_security_group_ids = [aws_security_group.instance.id]

    tags = {
        "Name"            = var.instance_name_tag
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}

# Define second instance
resource "aws_instance" "lev-instance2" {
    ami                                 = var.ami_id
    instance_type                       = var.instance_type
    subnet_id                           = aws_subnet.lev-doitDynamic-sub2.id
    associate_public_ip_address         = var.associate_public_ip_address
    iam_instance_profile                = "${aws_iam_instance_profile.instance_profile.name}"

    # key_name = [""]#TODO
    vpc_security_group_ids = [aws_security_group.instance.id]

    tags = {
        "Name"                          = var.instance_name_tag
        "created_by"                    = var.created_by
        "bootcamp"                      = var.bootcamp
        "expiration_date"               = var.expiration_date
        "creation_date"                 = var.creation_date
    }
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~Elastic Load Balancer~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




# Define our Elastic-Load-Balancer
resource "aws_elb" "lev-doitDynamic-elb" {
    name               = "lev-doitDynamic-elb"
    subnets = [aws_subnet.lev-doitDynamic-sub1.id, aws_subnet.lev-doitDynamic-sub2.id]
    security_groups = [aws_security_group.lb-sg.id]

    listener {
        instance_port     = 3000
        instance_protocol = "tcp"
        lb_port           = 80
        lb_protocol = "tcp"
  
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:3000/"
        interval            = 30
    }

    instances                   = [aws_instance.lev-instance1.id, aws_instance.lev-instance2.id]
    cross_zone_load_balancing   = true

    tags = {
        "Name"            = var.instance_name_tag
        "created_by"      = var.created_by
        "bootcamp"        = var.bootcamp
        "expiration_date" = var.expiration_date
        "creation_date"   = var.creation_date
    }
}




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~Setting the access to S3~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# resource "aws_iam_instance_profile" "instance_profile" {
#     name = "Instance-profile"
#     role = aws_iam_role.testing-role.name
# }


# resource "aws_iam_policy_attachment" "test-attach" {
#     name = "test-attachment"
#     roles = ["${aws_iam_role.testing-role.name}"]
#     policy_arn = "${aws_iam_policy.policy.arn}"
# }



# resource "aws_iam_role" "testing-role" {
#     name = "ec2_role"

#     assume_role_policy = jsonencode({
#         "Version": "2012-10-17",
#         "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#             "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#         ]
#     })
# }


# resource "aws_iam_policy" "policy" {

#     name = "test-policy"

#     policy = jsonencode({
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Effect": "Allow",
#                 "Action": [
#                     "s3:*",
#                     "s3-object-lambda:*"
#                 ],
#                 "Resource": "*"
#             }
#         ]
#     })
  
# }






