resource "aws_ecr_repository" "api_repository" {
  name = "whitespace-api"
}

resource "aws_ecr_repository" "frontend_repository" {
  name = "whitespace-frontend"
}
