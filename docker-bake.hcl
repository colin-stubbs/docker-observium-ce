variable "IMAGE" {
  default = "docker.io/colinstubbs/observium-ce"
}

variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["observium"]
}

target "observium" {
  context    = "./build"
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = ["${IMAGE}:${TAG}"]
}
