terraform {
  cloud {
    organization = "my_diploma"
    workspaces {
      name = "stage"
    }
}
}
