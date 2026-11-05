locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  memberships = merge([
    for user, cfg in var.users : {
      for group in cfg.groups : "${group}|${user}" => { group = group, user = user }
    }
  ]...)
}
