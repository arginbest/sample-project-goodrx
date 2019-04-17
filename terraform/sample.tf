
provider "aws" {
  region = "us-west-2"
}

variable "image_name" {
  default = "waltisfrozen/sample-project-goodrx"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "goodrx-dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }

}


resource "aws_instance" "goodrx-dev" {
  ami           = "ami-0a4f49b2488e15346"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.public_subnets[0]}"
  key_name = "${aws_key_pair.goodrx-dev.id}"
  security_groups = ["${aws_security_group.goodrx-dev.id}"]
  user_data = "${data.template_file.goodrx-dev.rendered}"

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "GoodRX-Coding-Challenge"
  }
}


data "template_file" "goodrx-dev" {
  template = "${file("${path.module}/userdata/goodrx-dev-launch-config.tpl")}"

  vars {
    image_name = "${var.image_name}"
  }
}

resource "aws_elb" "goodrx-dev" {
  name = "goodrx-dev"

  listener = {
    instance_port     = 8080
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.goodrx-dev-elb.id}"]
  subnets         = ["${module.vpc.public_subnets}"]
  instances       = ["${aws_instance.goodrx-dev.id}"]

  health_check = {
    target              = "HTTP:8080/status"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


resource "aws_key_pair" "goodrx-dev" {
  key_name   = "goodrx-dev"
  public_key = "${file("${path.module}/goodrx.pub")}"
}


resource "aws_security_group" "goodrx-dev" {
  name        = "goodrx-dev"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for EC2 instance"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "goodrx-dev-elb" {
  name        = "goodrx-dev-elb"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for ELB"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


resource "aws_security_group_rule" "goodrx-dev-8080" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.goodrx-dev.id}"
  source_security_group_id = "${aws_security_group.goodrx-dev-elb.id}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "goodrx-dev-egress-443" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.goodrx-dev.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "goodrx-dev-elb-80" {
  type              = "ingress"
  security_group_id = "${aws_security_group.goodrx-dev-elb.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "goodrx-dev-elb-8080" {
  type              = "ingress"
  security_group_id = "${aws_security_group.goodrx-dev-elb.id}"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
