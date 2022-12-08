resource "aws_key_pair" "sshkey" {
  key_name   = "sshkey"
  public_key = file(var.KEY_PATH)
}

resource "aws_instance" "cloud" {
  subnet_id     = aws_subnet.public.id
  instance_type = "t4g.nano"
  ami           = "ami-01b5ec3ed8678d8b7"
  key_name      = aws_key_pair.sshkey.key_name

  vpc_security_group_ids = [
    aws_security_group.cloud.id
  ]

  tags = {
    "Name" = "Cloud Instance"
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.cloud.id
  name    = "app.${aws_route53_zone.cloud.name}"
  ttl     = 300
  type    = "A"
  records = [aws_instance.cloud.private_ip]
}

output "cloud_private_ip" {
  value = aws_instance.cloud.private_ip
}