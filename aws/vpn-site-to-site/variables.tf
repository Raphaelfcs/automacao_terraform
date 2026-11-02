############################################
# transit_gateway_route_table_id — igual ao módulo v1: só é usado para as VPNs
# cujo target_gateway_type == "transit_gateway". Continua opcional e aditivo.
############################################
variable "transit_gateway_route_table_id" {
  description = <<-EOT
    ID de uma Transit Gateway Route Table JÁ EXISTENTE (ex: tgw-rtb-0123456789abcdef0)
    onde o(s) attachment(s) das VPNs com target_gateway_type = "transit_gateway" devem
    ser associados e ter suas rotas propagadas.

    IMPORTANTE (não destrutivo): aditivo, só afeta os NOVOS attachments criados aqui.
    Não recria, substitui nem apaga a route table, nem afeta associações/propagações/
    rotas de outros attachments já existentes (VPCs, outras VPNs, Direct Connect etc.).

    Deixe como null se não quiser que o módulo gerencie associação/propagação (ex:
    quando o TGW já tem "default route table association/propagation = true").
  EOT
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags comuns aplicadas a todos os recursos criados pelo módulo (cgw, vpn connection, etc.)."
  type        = map(string)
  default     = {}
}

############################################
# vpn_connections — mapa de VPNs Site-to-Site a criar. A CHAVE é um identificador
# curto e único (ex: "matriz-sp", "acme-rj"), usada para nomear os recursos
# na AWS e indexar os outputs. Suporta 1 ou N VPNs no mesmo apply, cada uma com o
# seu próprio target gateway, customer gateway, roteamento e opções de túnel —
# ou seja, VPNs diferentes podem ter destinos e configurações de túnel diferentes
# dentro do mesmo módulo.
#
# O objeto de cada VPN espelha 1:1 as opções do wizard "Create VPN Connection" do
# console AWS (Site-to-Site VPN). Os campos com "- optional" no console viram
# optional(...) aqui; quando não preenchidos, a AWS aplica os próprios defaults
# (equivalente a deixar "Use default options" marcado no console).
############################################
variable "vpn_connections" {
  type = map(object({
    # --- Details ---
    name_tag = optional(string) # "Name tag - optional". Vira a tag Name (senão usa "vpn-<chave>").

    # --- Target gateway type ---
    # Um dos 4 valores do console:
    #   "virtual_private_gateway" = Virtual private gateway
    #   "transit_gateway"         = Transit gateway
    #   "vpn_concentrator"        = Site-to-Site VPN Concentrator
    #   "not_associated"          = Not associated
    # O módulo NUNCA cria o VGW/TGW/Concentrator em si — informe o ID do recurso
    # já existente no campo correspondente abaixo.
    target_gateway_type = string

    transit_gateway_id  = optional(string) # obrigatório quando target_gateway_type = "transit_gateway"
    vpn_gateway_id      = optional(string) # obrigatório quando target_gateway_type = "virtual_private_gateway"
    vpn_concentrator_id = optional(string) # obrigatório quando target_gateway_type = "vpn_concentrator"

    # ID do attachment de Direct Connect/TGW usado como "transporte" da VPN,
    # necessário apenas quando outside_ip_address_type = "PrivateIpv4".
    transport_transit_gateway_attachment_id = optional(string)

    # --- Customer gateway ---
    # mode = "existing" reutiliza um Customer Gateway já existente na conta
    #        (informe customer_gateway_id).
    # mode = "new" faz o módulo criar um aws_customer_gateway novo (informe
    #        ip_address e bgp_asn; certificate_arn e device_name são opcionais).
    customer_gateway = object({
      mode                = string
      customer_gateway_id = optional(string) # obrigatório quando mode = "existing"
      ip_address          = optional(string) # obrigatório quando mode = "new". IP público do dispositivo do outro lado.
      bgp_asn             = optional(number) # obrigatório quando mode = "new". Exigido pela AWS mesmo em rota estática.
      bgp_asn_extended    = optional(number) # ASN de 4 bytes (>65535), alternativa a bgp_asn.
      certificate_arn     = optional(string) # ARN do certificado ACM Private CA, quando a autenticação é por certificado.
      device_name         = optional(string) # Nome/modelo do equipamento — só documentação no console AWS.
    })

    # --- Routing options ---
    # "dynamic" = Dynamic (requires BGP): o outro lado do túnel precisa falar BGP.
    # "static"  = Static: você lista os CIDRs remotos em static_routes.
    routing_option = string
    static_routes  = optional(list(string), []) # usado somente quando routing_option = "static"

    # --- Pre-shared key storage ---
    # "Standard"       = PSK fica só no estado da VPN connection (comportamento clássico).
    # "SecretsManager" = AWS armazena a PSK no Secrets Manager automaticamente
    #                    (ARN disponível depois no output preshared_key_arns).
    # Assim como tunnel_bandwidth/tunnel_inside_ip_version/enable_acceleration
    # abaixo, só é enviado à API quando target_gateway_type = "transit_gateway"
    # (ver comentário em main.tf) — para os demais target_gateway_type, o
    # módulo ignora este campo.
    preshared_key_storage = optional(string, "Standard")

    # --- Tunnel bandwidth ---
    # "standard" ou "large" (maior throughput por túnel). O console mostra
    # "Standard"/"Large" capitalizado, mas a API espera minúsculo — confirmado
    # em erro real do provider (expected tunnel_bandwidth to be one of
    # ["standard" "large"], got Standard). Só é enviado quando
    # target_gateway_type = "transit_gateway" — conflita com vpn_gateway_id
    # (confirmado em erro real do provider).
    tunnel_bandwidth = optional(string, "standard")

    # --- Tunnel inside IP version ---
    # "ipv4" (padrão) ou "ipv6". Só é enviado quando target_gateway_type =
    # "transit_gateway" (mesma família de restrição de tunnel_bandwidth).
    tunnel_inside_ip_version = optional(string, "ipv4")

    # --- Enable acceleration ---
    # Só é suportado pela AWS quando target_gateway_type = "transit_gateway"
    # (confirmado em erro real do provider: "enable_acceleration,transit_gateway_id"
    # devem ser especificados juntos). Para os demais target_gateway_type, o
    # módulo ignora este campo e não envia o argumento à API.
    enable_acceleration = optional(bool, false)

    # --- Outside IP address type ---
    # "PublicIpv4" (padrão) ou "PrivateIpv4" (exige transport_transit_gateway_attachment_id,
    # usado com Direct Connect como transporte da VPN).
    outside_ip_address_type = optional(string)

    # --- Local/Remote network CIDR ---
    # Domínio de criptografia do túnel. Se omitido, a AWS assume 0.0.0.0/0 (IPv4)
    # ou ::/0 (IPv6).
    local_ipv4_network_cidr  = optional(string) # rede do lado do customer gateway (on-premises)
    remote_ipv4_network_cidr = optional(string) # rede do lado AWS
    local_ipv6_network_cidr  = optional(string)
    remote_ipv6_network_cidr = optional(string)

    # --- Tunnel 1 / Tunnel 2 options - optional ---
    # Deixar um campo como null equivale a "Use default options" no console
    # (a AWS escolhe/gera automaticamente). Preencher um campo equivale a usar
    # "Edit tunnel N options" só para aquele parâmetro específico.
    tunnel1 = optional(object({
      inside_cidr      = optional(string) # bloco /30 dentro de 169.254.0.0/16
      inside_ipv6_cidr = optional(string) # bloco /126 dentro de fd00::/8, quando tunnel_inside_ip_version = "ipv6"
      preshared_key    = optional(string) # 8-64 caracteres [A-Za-z0-9_.], não pode começar com 0

      ike_versions = optional(list(string)) # subconjunto de ["ikev1", "ikev2"]

      phase1_encryption_algorithms = optional(list(string)) # subconjunto de ["AES128","AES256","AES128-GCM-16","AES256-GCM-16"]
      phase2_encryption_algorithms = optional(list(string))
      phase1_integrity_algorithms  = optional(list(string)) # subconjunto de ["SHA1","SHA2-256","SHA2-384","SHA2-512"]
      phase2_integrity_algorithms  = optional(list(string))
      phase1_dh_group_numbers      = optional(list(number)) # subconjunto de [2,14..24]
      phase2_dh_group_numbers      = optional(list(number)) # subconjunto de [2,5,14..24]

      phase1_lifetime_seconds = optional(number) # 900-28800
      phase2_lifetime_seconds = optional(number) # 900-3600, e deve ser < phase1_lifetime_seconds

      rekey_margin_time_seconds = optional(number) # 60 até metade do phase2_lifetime_seconds
      rekey_fuzz_percentage     = optional(number) # 0-100
      replay_window_size        = optional(number) # 64-2048

      dpd_timeout_seconds = optional(number) # >= 30
      dpd_timeout_action  = optional(string) # "clear" | "restart" | "none"
      startup_action      = optional(string) # "add" | "start"

      enable_tunnel_lifecycle_control = optional(bool) # "Tunnel endpoint lifecycle control"

      # VPN logging (CloudWatch Logs)
      log = optional(object({
        activity_log_enabled       = optional(bool, false) # "Tunnel activity log"
        activity_log_group_arn     = optional(string)
        activity_log_output_format = optional(string)      # "json" | "text"
        bgp_log_enabled            = optional(bool, false) # "Tunnel BGP log"
        bgp_log_group_arn          = optional(string)
        bgp_log_output_format      = optional(string) # "json" | "text"
      }), {})
    }), {})

    tunnel2 = optional(object({
      inside_cidr      = optional(string)
      inside_ipv6_cidr = optional(string)
      preshared_key    = optional(string)

      ike_versions = optional(list(string))

      phase1_encryption_algorithms = optional(list(string))
      phase2_encryption_algorithms = optional(list(string))
      phase1_integrity_algorithms  = optional(list(string))
      phase2_integrity_algorithms  = optional(list(string))
      phase1_dh_group_numbers      = optional(list(number))
      phase2_dh_group_numbers      = optional(list(number))

      phase1_lifetime_seconds = optional(number)
      phase2_lifetime_seconds = optional(number)

      rekey_margin_time_seconds = optional(number)
      rekey_fuzz_percentage     = optional(number)
      replay_window_size        = optional(number)

      dpd_timeout_seconds = optional(number)
      dpd_timeout_action  = optional(string)
      startup_action      = optional(string)

      enable_tunnel_lifecycle_control = optional(bool)

      log = optional(object({
        activity_log_enabled       = optional(bool, false)
        activity_log_group_arn     = optional(string)
        activity_log_output_format = optional(string)
        bgp_log_enabled            = optional(bool, false)
        bgp_log_group_arn          = optional(string)
        bgp_log_output_format      = optional(string)
      }), {})
    }), {})

    # Tags extras específicas dessa VPN, mescladas com var.tags.
    tags = optional(map(string), {})
  }))

  description = <<-EOT
    Mapa de VPNs Site-to-Site a serem criadas. Veja os comentários no type acima
    para o significado de cada campo — eles espelham 1:1 as opções do wizard
    "Create VPN Connection" do console AWS.
  EOT

  validation {
    condition     = length(var.vpn_connections) > 0
    error_message = "Informe pelo menos uma VPN no mapa vpn_connections."
  }

  # --- Target gateway type ---
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["virtual_private_gateway", "transit_gateway", "vpn_concentrator", "not_associated"], v.target_gateway_type)
    ])
    error_message = "target_gateway_type deve ser um de: virtual_private_gateway, transit_gateway, vpn_concentrator, not_associated."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.target_gateway_type != "transit_gateway" || v.transit_gateway_id != null
    ])
    error_message = "Toda VPN com target_gateway_type = \"transit_gateway\" precisa informar transit_gateway_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.target_gateway_type != "virtual_private_gateway" || v.vpn_gateway_id != null
    ])
    error_message = "Toda VPN com target_gateway_type = \"virtual_private_gateway\" precisa informar vpn_gateway_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.target_gateway_type != "vpn_concentrator" || v.vpn_concentrator_id != null
    ])
    error_message = "Toda VPN com target_gateway_type = \"vpn_concentrator\" precisa informar vpn_concentrator_id."
  }

  # enable_acceleration só existe para VPNs em Transit Gateway — avisa cedo em vez
  # de silenciosamente ignorar a intenção do usuário nos outros target_gateway_type.
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      !(v.enable_acceleration && v.target_gateway_type != "transit_gateway")
    ])
    error_message = "enable_acceleration = true só é suportado com target_gateway_type = \"transit_gateway\"."
  }

  # --- Customer gateway ---
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["existing", "new"], v.customer_gateway.mode)
    ])
    error_message = "customer_gateway.mode deve ser \"existing\" ou \"new\"."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.customer_gateway.mode != "existing" || v.customer_gateway.customer_gateway_id != null
    ])
    error_message = "Toda VPN com customer_gateway.mode = \"existing\" precisa informar customer_gateway.customer_gateway_id."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.customer_gateway.mode != "new" || (v.customer_gateway.ip_address != null && v.customer_gateway.bgp_asn != null)
    ])
    error_message = "Toda VPN com customer_gateway.mode = \"new\" precisa informar customer_gateway.ip_address e customer_gateway.bgp_asn."
  }

  # --- Routing options ---
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["dynamic", "static"], v.routing_option)
    ])
    error_message = "routing_option deve ser \"dynamic\" ou \"static\"."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.routing_option != "static" || length(v.static_routes) > 0
    ])
    error_message = "Toda VPN com routing_option = \"static\" precisa ter ao menos um CIDR em static_routes."
  }

  # --- Pre-shared key storage / Tunnel bandwidth / Tunnel inside IP version ---
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["Standard", "SecretsManager"], v.preshared_key_storage)
    ])
    error_message = "preshared_key_storage deve ser \"Standard\" ou \"SecretsManager\"."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["standard", "large"], v.tunnel_bandwidth)
    ])
    error_message = "tunnel_bandwidth deve ser \"standard\" ou \"large\" (minúsculo — é assim que a API espera, mesmo o console mostrando capitalizado)."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      contains(["ipv4", "ipv6"], v.tunnel_inside_ip_version)
    ])
    error_message = "tunnel_inside_ip_version deve ser \"ipv4\" ou \"ipv6\"."
  }

  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.outside_ip_address_type == null ? true : contains(["PublicIpv4", "PrivateIpv4"], v.outside_ip_address_type)
    ])
    error_message = "outside_ip_address_type deve ser null, \"PublicIpv4\" ou \"PrivateIpv4\"."
  }

  # Confirmado a partir de mensagem de erro real do provider AWS: outside_ip_address_type
  # = "PrivateIpv4" (usado com Direct Connect como transporte da VPN) exige
  # transport_transit_gateway_attachment_id.
  validation {
    condition = alltrue([
      for k, v in var.vpn_connections :
      v.outside_ip_address_type != "PrivateIpv4" || v.transport_transit_gateway_attachment_id != null
    ])
    error_message = "Toda VPN com outside_ip_address_type = \"PrivateIpv4\" precisa informar transport_transit_gateway_attachment_id."
  }

  # --- Tunnel 1 / Tunnel 2: IKE version, algoritmos, DH groups ---
  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.ike_versions == null ? true : alltrue([for x in t.ike_versions : contains(["ikev1", "ikev2"], x)])
        )
      ]
    ]))
    error_message = "tunnel{1,2}.ike_versions só aceita \"ikev1\" e/ou \"ikev2\"."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase1_encryption_algorithms == null ? true : alltrue([for x in t.phase1_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], x)])
          ) && (
          t.phase2_encryption_algorithms == null ? true : alltrue([for x in t.phase2_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], x)])
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase{1,2}_encryption_algorithms só aceita AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase1_integrity_algorithms == null ? true : alltrue([for x in t.phase1_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], x)])
          ) && (
          t.phase2_integrity_algorithms == null ? true : alltrue([for x in t.phase2_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], x)])
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase{1,2}_integrity_algorithms só aceita SHA1, SHA2-256, SHA2-384, SHA2-512."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase1_dh_group_numbers == null ? true : alltrue([for x in t.phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], x)])
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase1_dh_group_numbers só aceita 2, 14-24."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase2_dh_group_numbers == null ? true : alltrue([for x in t.phase2_dh_group_numbers : contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], x)])
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase2_dh_group_numbers só aceita 2, 5, 14-24."
  }

  # --- Tunnel 1 / Tunnel 2: lifetimes, rekey, replay window, DPD ---
  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase1_lifetime_seconds == null ? true : (t.phase1_lifetime_seconds >= 900 && t.phase1_lifetime_seconds <= 28800)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase1_lifetime_seconds deve estar entre 900 e 28800."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.phase2_lifetime_seconds == null ? true : (t.phase2_lifetime_seconds >= 900 && t.phase2_lifetime_seconds <= 3600)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase2_lifetime_seconds deve estar entre 900 e 3600."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          (t.phase1_lifetime_seconds == null || t.phase2_lifetime_seconds == null) ? true : (t.phase2_lifetime_seconds < t.phase1_lifetime_seconds)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.phase2_lifetime_seconds precisa ser menor que phase1_lifetime_seconds."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.rekey_fuzz_percentage == null ? true : (t.rekey_fuzz_percentage >= 0 && t.rekey_fuzz_percentage <= 100)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.rekey_fuzz_percentage deve estar entre 0 e 100."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          (t.rekey_margin_time_seconds == null || t.phase2_lifetime_seconds == null) ? true : (t.rekey_margin_time_seconds >= 60 && t.rekey_margin_time_seconds <= (t.phase2_lifetime_seconds / 2))
        )
      ]
    ]))
    error_message = "tunnel{1,2}.rekey_margin_time_seconds deve estar entre 60 e metade de phase2_lifetime_seconds."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.replay_window_size == null ? true : (t.replay_window_size >= 64 && t.replay_window_size <= 2048)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.replay_window_size deve estar entre 64 e 2048."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.dpd_timeout_seconds == null ? true : t.dpd_timeout_seconds >= 30
        )
      ]
    ]))
    error_message = "tunnel{1,2}.dpd_timeout_seconds deve ser 30 ou maior."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.dpd_timeout_action == null ? true : contains(["clear", "restart", "none"], t.dpd_timeout_action)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.dpd_timeout_action deve ser \"clear\", \"restart\" ou \"none\"."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.vpn_connections : [
        for t in [v.tunnel1, v.tunnel2] : (
          t.startup_action == null ? true : contains(["add", "start"], t.startup_action)
        )
      ]
    ]))
    error_message = "tunnel{1,2}.startup_action deve ser \"add\" ou \"start\"."
  }
}
