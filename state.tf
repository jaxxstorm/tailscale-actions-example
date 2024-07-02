terraform {
  cloud {
    organization = "lbrlabs"

    workspaces {
      name = "main"
    }
  }
}