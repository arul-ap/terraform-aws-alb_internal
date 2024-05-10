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

module "alb_internal" {
  source = "arul-ap/alb_internal/aws"
  org    = "abc"
  proj   = "proj-x"
  env    = "dev"

  alb = {
    name              = "backend-end"
    subnet_id         = [module.vpc.private_subnet_id["app-subnet-01"], module.vpc.private_subnet_id["app-subnet-02"], module.vpc.private_subnet_id["app-subnet-03"]]
    security_group_id = [module.vpc.sg_id["app-sg"]]
  }

  alb_listeners_http = {
    http_80 = {
      port       = 80
      default_tg = "http-tg-01"
    }
  }

  alb_listeners_https = {
    https_443 = {
      port             = 443
      default_cert_arn = "" //insert cert ARN from ACM
      default_tg       = "https-tg-01"
    }
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
      listener = "https_443"
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
      listener = https_443
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
      listener = https_443
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