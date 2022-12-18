resource "aws_key_pair" "sshkey" {
  key_name   = "sshkey"
  public_key = file(var.KEY_PATH)
}

# VPN instance

resource "aws_instance" "vpn" {
  subnet_id         = aws_subnet.public.id
  instance_type     = "t4g.nano"
  ami               = "ami-0f91cedb707b09db0"
  key_name          = aws_key_pair.sshkey.key_name
  source_dest_check = false

  vpc_security_group_ids = [
    aws_security_group.premise.id,
    aws_security_group.vpn.id
  ]

  tags = {
    "Name" = "Premise VPN"
  }
}

resource "aws_eip" "vpn" {
  vpc = true
  tags = {
    "Name" = "VPN IP"
  }
}

resource "aws_eip_association" "vpn" {
  instance_id   = aws_instance.vpn.id
  allocation_id = aws_eip.vpn.id
}

# App instance

resource "aws_instance" "app" {
  subnet_id     = aws_subnet.private_a.id
  instance_type = "t4g.nano"
  ami           = "ami-0f91cedb707b09db0"
  key_name      = aws_key_pair.sshkey.key_name

  vpc_security_group_ids = [
    aws_security_group.premise.id
  ]

  tags = {
    "Name" = "Premise Instance"
  }
}

# DNS instance

resource "aws_instance" "dns" {
  subnet_id     = aws_subnet.private_b.id
  instance_type = "t4g.nano"
  ami           = "ami-0f91cedb707b09db0"
  key_name      = aws_key_pair.sshkey.key_name

  vpc_security_group_ids = [
    aws_security_group.premise.id,
    aws_security_group.vpn.id
  ]

  tags = {
    "Name" = "Premise DNS"
  }
}


output "vpn_eip" {
  value = aws_eip.vpn.public_ip
}

output "app_ip" {
  value = aws_instance.app.private_ip
}

output "dns_ip" {
  value = aws_instance.dns.private_ip
}
