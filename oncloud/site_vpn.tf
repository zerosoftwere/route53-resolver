
resource "aws_vpn_gateway" "cloud_vg" {
  tags = {
    "Name" = "Cloud VGW"
  }
}

resource "aws_vpn_gateway_attachment" "cloud_vga" {
  vpc_id         = aws_vpc.cloud.id
  vpn_gateway_id = aws_vpn_gateway.cloud_vg.id
}

resource "aws_customer_gateway" "cloud_cg" {
  bgp_asn    = 65000
  type       = "ipsec.1"
  ip_address = var.ON_PREMISE_VPN_IP

  tags = {
    "Name" = "Cloud CGW"
  }
}

resource "aws_vpn_connection" "cloud_vpnc" {
  customer_gateway_id      = aws_customer_gateway.cloud_cg.id
  vpn_gateway_id           = aws_vpn_gateway.cloud_vg.id
  type                     = "ipsec.1"
  static_routes_only       = true
  local_ipv4_network_cidr  = "10.20.0.0/16"
  remote_ipv4_network_cidr = "10.10.0.0/16"

  tags = {
    "Name" = "Cloud"
  }
}

resource "aws_vpn_connection_route" "cloud_vpnr" {
  destination_cidr_block = "10.20.0.0/16"
  vpn_connection_id      = aws_vpn_connection.cloud_vpnc.id
}

resource "aws_vpn_gateway_route_propagation" "cloud_vpnrtp" {
  vpn_gateway_id = aws_vpn_gateway.cloud_vg.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpn_gateway_route_propagation" "cloud_vpn_private_rtp" {
  vpn_gateway_id = aws_vpn_gateway.cloud_vg.id
  route_table_id = aws_route_table.private.id
}