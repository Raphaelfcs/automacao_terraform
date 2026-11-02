locals {
  # Chave estática (índice da tabela + CIDR) para o for_each não depender de valores do apply.
  routes = {
    for pair in setproduct(range(length(var.route_table_ids)), var.remote_cidrs) :
    "${pair[0]}-${pair[1]}" => { route_table_id = var.route_table_ids[pair[0]], cidr = pair[1] }
  }
}
