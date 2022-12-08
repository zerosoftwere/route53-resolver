resource "aws_route53_zone" "cloud" {
  name = "cloud.internal"
  vpc {
    vpc_id = aws_vpc.cloud.id
  }
}