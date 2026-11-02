locals {
  has_org = var.org_id != ""
  # Com organização, o projeto nasce dentro da pasta; sem organização, fica sem pai.
  folder_id = local.has_org ? google_folder.lab[0].name : null
  policies  = local.has_org ? toset(var.boolean_policies) : toset([])
}
