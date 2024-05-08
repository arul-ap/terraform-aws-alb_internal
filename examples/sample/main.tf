terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = var.default_tags
  }
}

module "alb_public" {
  source = "arul-ap/alb_public/aws"
  org    = "abc"
  proj   = "proj-x"
  env    = "dev"

  alb = {
    name              = "frond-end"
    subnet_id         = [module.vpc.public_subnet_id["web-subnet-01"], module.vpc.public_subnet_id["web-subnet-02"], module.vpc.public_subnet_id["web-subnet-03"]]
    security_group_id = [module.vpc.sg_id["web-sg"]]
    default_cert_arn  = "" //insert cert ARN from ACM
    default_tg        = "tg-01"
  }
  target_groups = {
    tg-01 = {
      vpc_id    = module.vpc.vpc_id
      protocol  = "HTTP"
      port      = 80
      target_id = [module.ec2.ec2_id["web-01"]]
    }
    tg-02 = {
      vpc_id    = module.vpc.vpc_id
      protocol  = "HTTP"
      port      = 80
      target_id = [module.ec2.ec2_id["web-02"]]
    }
    tg-03 = {
      vpc_id   = module.vpc.vpc_id
      protocol = "HTTP"
      port     = 80
    }
  }
  certs_arn = { //additional certs to import to ALB
    // cert-01 = "" 
    // cert-02 = ""
  }
  rules = {
    rule-01 = {
      priority = 100
      condition = {
        host_header = ["example.com"]
      }
      action = {
        action_type  = "forward"
        target_group = "tg-01"
      }
    }
    rule-02 = {
      priority = 101
      condition = {
        host_header = ["*.abc.com"]
      }
      action = {
        action_type = "redirect"
        redirect = {
          port        = 443
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
    }
    rule-03 = {
      priority = 103
      condition = {
        host_header = ["example.org"]
      }
      action = {
        action_type  = "forward"
        target_group = "tg-03"
      }
    }
  }
}