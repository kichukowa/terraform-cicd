resource "google_compute_firewall" "allow-http-https" {
  name     = "allow-http-https"
  network  = var.vpc
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}