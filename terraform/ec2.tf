resource "aws_spot_instance_request" "cheap_worker" {
  count                           = local.LENGTH
  ami                             = "ami-074df373d6bafa625"
  spot_price                      = "0.0031"
  instance_type                   = "t3.micro"
  vpc_security_group_ids          = ["sg-0a3395ef37041658b"]
  wait_for_fulfillment            = true

  tags                            = {
    Name                          = element(var.COMPONENTS, count.index)
  }
}

resource "aws_ec2_tag" "name-tag" {
  count                           = local.LENGTH
  resource_id                     = element(aws_spot_instance_request.cheap_worker.*.spot_instance_id,count.index)
  key                             = "Name"
  value                           = element(var.COMPONENTS,count.index)
}

resource "aws_route53_record" "records" {
  count                           = local.LENGTH
  zone_id                         = "Z0821647W15DL3WPSKX8"
  name                            = element(var.COMPONENTS,count.index)
  type                            = "A"
  ttl                             = "300"
  records                         = [element(aws_spot_instance_request.cheap_worker.*.private_ip, count.index)]
}

locals {
  LENGTH                          = length(var.COMPONENTS)
}

//COMPONENTS = ["frontend","catalogue","user","mongodb","redis","rabbitmq","mysql","payment","shipping","cart"]

//resource "local_file" "foo" {
//  content     = "[FRONTEND]\n ${aws_spot_instance_request.cheap_worker.*.private_ip[0]}"
//  filename    = "/tmp/inv-roboshop"
//}