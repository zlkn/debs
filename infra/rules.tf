resource "cloudflare_ruleset" "cache" {
  zone_id = data.cloudflare_zone.this.id
  name    = "cache"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules = [{
    description = "Cache immutable packages in pool"
    expression  = "(http.host eq \"apt.${var.zone_name}\" and starts_with(http.request.uri.path, \"/pool/\"))"
    action      = "set_cache_settings"
    action_parameters = {
      cache = true
      edge_ttl = {
        mode    = "override_origin"
        default = 31536000
      }
    }
  }]
}

resource "cloudflare_ruleset" "ratelimit" {
  zone_id = data.cloudflare_zone.this.id
  name    = "ratelimit"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules = [{
    description = "Limit apt repository requests per IP"
    expression  = "(starts_with(http.request.uri.path, \"/pool/\") or starts_with(http.request.uri.path, \"/dists/\"))"
    action      = "block"
    ratelimit = {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 10
      requests_per_period = 50
      mitigation_timeout  = 10
    }
  }]
}
