resource "aws_spot_instance_request" "app-instances" {
  count                           = local.APP_LENGTH
  ami                             = "ami-074df373d6bafa625"
  spot_price                      = "0.0031"
  instance_type                   = "t3.micro"
  vpc_security_group_ids          = ["sg-0a3395ef37041658b"]
  wait_for_fulfillment            = true
  Monitor                         = "yes"

  tags                            = {
    Name                          = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
  }
}


resource "aws_spot_instance_request" "db-instances" {
  count                           = local.DB_LENGTH
  ami                             = "ami-074df373d6bafa625"
  spot_price                      = "0.0031"
  instance_type                   = "t3.micro"
  vpc_security_group_ids          = ["sg-0a3395ef37041658b"]
  wait_for_fulfillment            = true

  tags                            = {
    Name                          = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
  }
}

resource "aws_ec2_tag" "name-tag-app" {
  count                           = local.APP_LENGTH
  resource_id                     = element(aws_spot_instance_request.app-instances.*.spot_instance_id,count.index)
  key                             = "Name"
  value                           = "${element(var.APP_COMPONENTS,count.index)}-${var.ENV}"
}

resource "aws_ec2_tag" "name-tag-db" {
  count                           = local.DB_LENGTH
  resource_id                     = element(aws_spot_instance_request.db-instances.*.spot_instance_id,count.index)
  key                             = "Name"
  value                           = "${element(var.DB_COMPONENTS,count.index)}-${var.ENV}"
}

resource "aws_route53_record" "app-records" {
  count                           = local.APP_LENGTH
  zone_id                         = "Z0821647W15DL3WPSKX8"
  name                            = "${element(var.APP_COMPONENTS,count.index)}-${var.ENV}"
  type                            = "A"
  ttl                             = "300"
  records                         = [element(aws_spot_instance_request.app-instances.*.private_ip, count.index)]
}

resource "aws_route53_record" "db-records" {
  count                           = local.DB_LENGTH
  zone_id                         = "Z0821647W15DL3WPSKX8"
  name                            = "${element(var.DB_COMPONENTS,count.index)}-${var.ENV}"
  type                            = "A"
  ttl                             = "300"
  records                         = [element(aws_spot_instance_request.db-instances.*.private_ip, count.index)]
}

locals {
  APP_LENGTH                      = length(var.APP_COMPONENTS)
}
locals {
  DB_LENGTH                       = length(var.DB_COMPONENTS)
}

//COMPONENTS = ["frontend","catalogue","user","mongodb","redis","rabbitmq","mysql","payment","shipping","cart"]

//resource "local_file" "inventory-file" {
//  content     =   "[FRONTEND]\n${local.COMPONENTS[0]}\n[CATALOGUE]\n${local.COMPONENTS[1]}\n[USER]\n${local.COMPONENTS[2]}\n[MONGODB]\n${local.COMPONENTS[3]}\n[REDIS]\n${local.COMPONENTS[4]}\n[RABBITMQ]\n${local.COMPONENTS[5]}\n[MYSQL]\n${local.COMPONENTS[6]}\n[PAYMENT]\n${local.COMPONENTS[7]}\n[SHIPPING]\n${local.COMPONENTS[8]}\n[CART]\n${local.COMPONENTS[9]}"
//  filename    =   "/tmp/inv-roboshop-${var.ENV}"
//}


//APP_COMPONENTS = ["frontend","catalogue","user","payment","shipping","cart"]
//DB_COMPONENTS  = ["mongodb","redis","rabbitmq","mysql"]

resource "local_file" "inventory-file" {
  content     =   "[FRONTEND]\n${aws_spot_instance_request.app-instances.*.private_ip[0]}\n[CATALOGUE]\n${aws_spot_instance_request.app-instances.*.private_ip[1]}\n[USER]\n${aws_spot_instance_request.app-instances.*.private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.db-instances.*.private_ip[0]}\n[REDIS]\n${aws_spot_instance_request.db-instances.*.private_ip[1]}\n[RABBITMQ]\n${aws_spot_instance_request.db-instances.*.private_ip[2]}\n[MYSQL]\n${aws_spot_instance_request.db-instances.*.private_ip[3]}\n[PAYMENT]\n${aws_spot_instance_request.app-instances.*.private_ip[3]}\n[SHIPPING]\n${aws_spot_instance_request.app-instances.*.private_ip[4]}\n[CART]\n${aws_spot_instance_request.app-instances.*.private_ip[5]}"
  filename    =   "/tmp/inv-roboshop-${var.ENV}"
}


//locals {
//  COMPONENTS = concat(var.APP_COMPONENTS, var.DB_COMPONENTS)
//}
//
//resource "local_file" "inventory-file" {
//  content     =   "[FRONTEND]\n${local.COMPONENTS[0]}\n[CATALOGUE]\n${local.COMPONENTS[1]}\n[USER]\n${local.COMPONENTS[2]}\n[MONGODB]\n${local.COMPONENTS[3]}\n[REDIS]\n${local.COMPONENTS[4]}\n[RABBITMQ]\n${local.COMPONENTS[5]}\n[MYSQL]\n${local.COMPONENTS[6]}\n[PAYMENT]\n${local.COMPONENTS[7]}\n[SHIPPING]\n${local.COMPONENTS[8]}\n[CART]\n${local.COMPONENTS[9]}"
//  filename    =   "/tmp/inv-roboshop-${var.ENV}"
//}

