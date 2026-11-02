locals {
  https_domain = "${google_compute_global_address.lb.address}.nip.io"
}
