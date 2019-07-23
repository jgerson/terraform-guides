terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region = "us-west-2"
}

variable "vpc_name" {
  description = "name of the VPC"
  default = "tf-0.12-fce-example"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "172.16.10.0/24"

  tags = {
    Name = "tf-0.12-fce-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.101"]
  
  tags = {
    Name = "tf-0.12-fce-primary_network_interface"
  }
}

resource "aws_network_interface" "bar" {
  subnet_id = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]
  
  tags = {
    Name = "tf-0.12-fce-primary_network_interface"
  }
}

data "aws_ami" "ubuntu_14_04" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm/ubuntu-trusty-14.04-amd64-server-*"]
  }

  owners     = ["099720109477"]
}

resource "aws_instance" "foo" {
  ami = data.aws_ami.ubuntu_14_04.image_id
  instance_type = "t2.micro"

  tags = {
    Name = "tf-0.12-fce-ec2-instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index = 0
  }
}

resource "aws_instance" "bar" {
  ami = data.aws_ami.ubuntu_14_04.image_id
  instance_type = "t2.micro"

  tags = {
    Name = "tf-0.12-fce-ec2-instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.bar.id
    device_index = 0
  }
}

output "private_dns" {
  value = aws_instance.foo.private_dns
}

resource "aws_ebs_volume" "example" {
  availability_zone = "us-west-2a"
  size              = 40

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/EC2",
                   "CPUUtilization",
                   "InstanceId",
                   "i-012345"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"us-east-1",
             "title":"EC2 Instance CPU"
          }
       },
       {
          "type":"text",
          "x":0,
          "y":7,
          "width":3,
          "height":3,
          "properties":{
             "markdown":"Hello world"
          }
       }
   ]
 }
 EOF
}
