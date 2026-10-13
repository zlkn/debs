data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

resource "cloudflare_r2_bucket" "repo" {
  account_id = var.account_id
  name       = var.repo_bucket
}

resource "cloudflare_r2_bucket" "state" {
  account_id = var.account_id
  name       = var.state_bucket
}

resource "cloudflare_r2_custom_domain" "apt" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.repo.name
  domain      = "apt.${var.zone_name}"
  zone_id     = data.cloudflare_zone.this.id
  enabled     = true
  min_tls     = "1.2"
}

resource "cloudflare_pages_project" "web" {
  account_id        = var.account_id
  name              = var.pages_project
  production_branch = "main"
}

resource "cloudflare_pages_domain" "web" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.web.name
  name         = "packages.${var.zone_name}"
}

resource "cloudflare_dns_record" "web" {
  zone_id = data.cloudflare_zone.this.id
  name    = "packages.${var.zone_name}"
  type    = "CNAME"
  content = cloudflare_pages_project.web.subdomain
  proxied = true
  ttl     = 1
}
