variable "account_id" {
  type    = string
  default = "dc3d95e1d200d212f046cfd5724c833e"
}

variable "zone_name" {
  type    = string
  default = "zlkn.cc"
}

variable "repo_bucket" {
  type    = string
  default = "debs"
}

variable "state_bucket" {
  type    = string
  default = "debs-tfstate"
}

variable "pages_project" {
  type    = string
  default = "debs"
}
