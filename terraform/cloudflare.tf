resource "cloudflare_record" "example" {
  depends_on = [google_compute_instance.nginx-vm]
  zone_id    = var.cloudflare_zone_id
  name       = var.dns_record
  value      = google_compute_instance.nginx-vm.network_interface[0].access_config[0].nat_ip
  type       = "A"
  ttl        = 1
  proxied    = false
}