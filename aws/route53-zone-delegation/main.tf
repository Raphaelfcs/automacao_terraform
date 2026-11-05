# Interconexão de DNS entre contas: delega um subdomínio (zona filha em outra conta, ex.:
# dev.example.com) criando o registro NS na zona pai (ex.: example.com na conta de produção).
# Fica num estado próprio, separado das duas zonas, para que nenhuma delas dependa do ciclo de
# vida da outra; os servidores de nome chegam por saída/parâmetro da zona filha.

resource "aws_route53_record" "delegation" {
  zone_id = var.parent_zone_id
  name    = var.subdomain
  type    = "NS"
  ttl     = var.ttl
  records = var.name_servers
}
