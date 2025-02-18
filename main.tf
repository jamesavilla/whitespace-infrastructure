terraform {
  backend "remote" {
    organization = "whitespace"

    workspaces {
      name = "default"
    }
  }
}