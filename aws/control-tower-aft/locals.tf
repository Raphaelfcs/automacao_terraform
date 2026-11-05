locals {
  tags = merge({ Gerenciado = "terraform", Camada = "landing-zone", Componente = "aft" }, var.tags)

  # Os quatro repositórios que o AFT observa. Para GitHub o nome é "<org>/<repo>".
  repos = {
    for k, name in var.repositories : k => var.vcs_provider == "codecommit" ? name : "${var.repository_owner}/${name}"
  }
}
