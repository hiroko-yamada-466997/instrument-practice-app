resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repositories)
  name                 = "${var.name}/${each.value}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false
  image_scanning_configuration {
    scan_on_push = true

  }
  encryption_configuration {
    encryption_type = "AES256"

  }
  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1, description = "Keep 20 most recent images", selection = {
        tagStatus = "any", countType = "imageCountMoreThan", countNumber = 20
        }, action = {
        type = "expire"
      }
    }]
  })
}
