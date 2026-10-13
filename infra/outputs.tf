output "apt_url" {
  value = "https://${cloudflare_r2_custom_domain.apt.domain}"
}

output "web_url" {
  value = "https://${cloudflare_pages_domain.web.name}"
}

output "pages_subdomain" {
  value = cloudflare_pages_project.web.subdomain
}
