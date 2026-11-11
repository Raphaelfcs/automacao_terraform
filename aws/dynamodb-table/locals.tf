locals {
  # Atributos declarados = chaves da tabela + chaves dos índices (DynamoDB exige só os usados em chaves).
  key_names = compact(concat(
    [var.hash_key, var.range_key],
    flatten([for i in values(var.global_secondary_indexes) : [i.hash_key, i.range_key]])
  ))
  attributes = { for n in distinct(local.key_names) : n => lookup(var.attribute_types, n, "S") }
}
