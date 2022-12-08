resource "aws_route53_zone" "premise" {
  name = "premise.internal"
  vpc {
    vpc_id = aws_vpc.premise.id
  }
}