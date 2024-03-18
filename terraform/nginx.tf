resource "google_compute_instance" "nginx-vm" {
  depends_on   = [google_compute_firewall.allow-http-https]
  name         = "nginx-vm"
  machine_type = "n2-standard-2"
  zone         = "europe-west3-c"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = var.vpc

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<EOF
    apt update
    apt install nginx -y
    systemctl start nginx
    systemctl enable nginx
    rm /etc/nginx/sites-available/default
    rm /etc/nginx/sites-enabled/default
    echo '${file("../web/index.html")}' > /var/www/html/index.html
    echo '${file("../web/nginx.conf")}' > /etc/nginx/sites-available/default
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
    apt install certbot python3-certbot-nginx -y
    certbot --nginx -d ${var.domain_name} --non-interactive --agree-tos --email ${var.personal_email} --redirect
    systemctl restart nginx

EOF

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account_email
    scopes = [var.service_account_scope]
  }
}

output "vm_ip_address" {
  value = google_compute_instance.nginx-vm.network_interface[0].access_config[0].nat_ip
}

output "website_will_be_available_shortly_on_the_following_domain" {
  value = var.domain_name
}