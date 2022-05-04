provider "aws" {
  region = "ap-south-1"
}

locals {

env = terraform.workspace

  counts = {
    "default" = 1
    "dev"    = 1
    "qa"    = 1
    "stage" = 1
  }


  instances = {
    "default" = "t2.micro"
    "dev"    = "t2.micro"
    "qa"    = "t2.micro"
    "stage" = "t2.micro"
  }


  tags = {
    "default" = "webserver-def"
    "dev"    = "DEV"
    "qa"    = "QA"
    "stage" = "Stage"
  }
  
  instance_type = lookup(local.instances, local.env)
  count= lookup(local.counts, local.env)
  mytag= lookup(local.tags, local.env)


}




resource "aws_instance" "my_work" {
  ami= "ami-0447a12f28fddb066"
  instance_type = local.instance_type
  count= local.count
  tags = {
    Name = "${local.mytag}"
  }

/*
}
terraform {
  backend "s3" {
    region  = "ap-south-1"
    bucket  = "s3-dev-qa-stage"
    key     = "state.tfstate"
    encrypt = true #AES-256 encryption
  }*/
}
