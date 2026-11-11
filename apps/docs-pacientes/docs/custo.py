"""Modelo de custo mensal (USD) da plataforma de documentos de pacientes, ativo-ativo AWS + GCP.

Uso: python3 custo.py            -> tabela em Markdown para 20, 100 e 3000 clínicas (mês 12)
     python3 custo.py 250        -> só para 250 clínicas

Preços de tabela de referência (sa-east-1 e southamerica-east1, nov/2026), sem impostos e sem
descontos. São estimativas para decisão de arquitetura: confira na AWS Pricing Calculator e na
Google Cloud Pricing Calculator antes de contratar. Cada premissa está nomeada abaixo para ser
ajustada com dados reais de uso.
"""
import sys

# ---------------------------------------------------------------- premissas de uso por clínica/mês
DOCS_POR_CLINICA = 150          # PDFs enviados por mês
MB_POR_DOC = 0.8                # tamanho médio do PDF
DOWNLOADS_POR_DOC = 2           # paciente + equipe
PACIENTES_ATIVOS = 100          # pacientes que entram no app no mês (MAU)
EQUIPE_POR_CLINICA = 8          # usuários da clínica (MAU)
REQ_API_POR_CLINICA = 10_000    # chamadas de API (listar, baixar, enviar, login)
MESES_ACUMULADOS = 12           # armazenamento acumulado (retenção longa: nada é apagado)
FRACAO_AWS = 0.5                # ativo-ativo: metade do tráfego em cada nuvem (DNS ponderado)

# ---------------------------------------------------------------- preços AWS (sa-east-1)
AWS = dict(
    s3_std_gb=0.0405, s3_ia_gb=0.0221, s3_put_1k=0.007, s3_get_1k=0.00056,
    ddb_wru_m=0.94, ddb_rru_m=0.19, ddb_gb=0.3825,
    lambda_gbs=0.0000166667, lambda_req_m=0.20, lambda_free_gbs=400_000, lambda_free_req=1_000_000,
    apigw_http_m=1.90,
    egress_gb=0.15,
    kms_key=1.0, kms_10k=0.03,
    cognito_free_mau=10_000, cognito_essentials_mau=0.015,   # Essentials: login gerenciado em português
    r53_zone=0.50, r53_hc=4.25,          # 2 health checks HTTPS (CloudFront + IP do GCP)
    waf_acl=5.0, waf_rule=1.0, waf_rules=4, waf_req_m=0.60,
    cw_logs_gb=0.75, cw_alarm=0.10, alarmes=10,
)
# ---------------------------------------------------------------- preços GCP (southamerica-east1)
GCP = dict(
    gcs_std_gb=0.035, gcs_nearline_gb=0.020, gcs_a_1k=0.005, gcs_b_1k=0.0004,
    fs_read_100k=0.06, fs_write_100k=0.18, fs_gb=0.18, fs_free_reads_mes=1_500_000, fs_free_writes_mes=600_000,
    run_vcpu_s=0.0000336, run_gib_s=0.0000035, run_req_m=0.40,
    run_free_vcpu_s=180_000, run_free_gib_s=360_000, run_free_req=2_000_000,
    lb_regras=18.25, lb_gib=0.008,
    armor_politica=5.0, armor_regra=1.0, armor_regras=4, armor_req_m=0.75, armor_managed_req_m=0.75,
    egress_gb=0.12,
    kms_versao=0.06, kms_10k=0.03,
)


def custo(clinicas):
    docs = clinicas * DOCS_POR_CLINICA
    gb_mes = docs * MB_POR_DOC / 1024
    gb_total = gb_mes * MESES_ACUMULADOS                 # cada nuvem guarda uma cópia completa
    gb_quente, gb_frio = gb_mes, gb_total - gb_mes       # 30 dias em classe padrão, depois IA/Nearline
    downloads = docs * DOWNLOADS_POR_DOC
    gb_download = downloads * MB_POR_DOC / 1024
    req = clinicas * REQ_API_POR_CLINICA
    mau = clinicas * (PACIENTES_ATIVOS + EQUIPE_POR_CLINICA)
    itens_gravados = docs * 4 + req * 0.05               # documento, status, auditoria, réplica
    itens_lidos = req * 3

    a, g = {}, {}
    fa, fg = FRACAO_AWS, 1 - FRACAO_AWS
    # ------------------------------------------------ AWS
    a['S3 (2 classes + requisições)'] = gb_quente * AWS['s3_std_gb'] + gb_frio * AWS['s3_ia_gb'] + docs * 2 / 1000 * AWS['s3_put_1k'] + downloads / 1000 * AWS['s3_get_1k']
    a['DynamoDB on-demand + PITR'] = itens_gravados / 1e6 * AWS['ddb_wru_m'] + itens_lidos * fa / 1e6 * AWS['ddb_rru_m'] + (docs * MESES_ACUMULADOS * 2 / 1e6) * AWS['ddb_gb'] * 2
    gbs = (req * fa * 0.3 + docs * 3) * 0.512          # 512 MB, ~300 ms
    a['Lambda (API, eventos, réplica)'] = max(0, gbs - AWS['lambda_free_gbs']) * AWS['lambda_gbs'] + max(0, req * fa + docs * 3 - AWS['lambda_free_req']) / 1e6 * AWS['lambda_req_m']
    a['API Gateway HTTP'] = req * fa / 1e6 * AWS['apigw_http_m']
    a['Saída de dados (downloads + réplica p/ GCP)'] = (gb_download * fa + gb_mes * fa) * AWS['egress_gb']
    a['KMS (2 chaves + uso)'] = 2 * AWS['kms_key'] + (docs * 6 + req * fa) / 1e4 * AWS['kms_10k']
    a['Cognito Essentials (2 pools)'] = max(0, mau - AWS['cognito_free_mau']) * AWS['cognito_essentials_mau']
    a['Route 53 (zona + health checks)'] = AWS['r53_zone'] + AWS['r53_hc']
    a['WAF na CloudFront'] = AWS['waf_acl'] + AWS['waf_rule'] * AWS['waf_rules'] + req * fa / 1e6 * AWS['waf_req_m']
    a['CloudWatch (logs + 10 alarmes)'] = max(1.0, req * fa * 2e-6) * AWS['cw_logs_gb'] + AWS['alarmes'] * AWS['cw_alarm']
    # ------------------------------------------------ GCP
    g['Cloud Storage (2 classes + operações)'] = gb_quente * GCP['gcs_std_gb'] + gb_frio * GCP['gcs_nearline_gb'] + docs * 2 / 1000 * GCP['gcs_a_1k'] + downloads / 1000 * GCP['gcs_b_1k']
    g['Firestore + PITR'] = max(0, itens_gravados - GCP['fs_free_writes_mes']) / 1e5 * GCP['fs_write_100k'] + max(0, itens_lidos * fg - GCP['fs_free_reads_mes']) / 1e5 * GCP['fs_read_100k'] + (docs * MESES_ACUMULADOS * 2 / 1e6) * GCP['fs_gb'] * 2
    vcpu_s = (req * fg + docs * 3) * 0.3
    g['Cloud Run (API e eventos, mínimo 0)'] = max(0, vcpu_s - GCP['run_free_vcpu_s']) * GCP['run_vcpu_s'] + max(0, vcpu_s * 0.5 - GCP['run_free_gib_s']) * GCP['run_gib_s'] + max(0, req * fg + docs * 3 - GCP['run_free_req']) / 1e6 * GCP['run_req_m']
    g['Load Balancer global'] = GCP['lb_regras'] + (gb_download * fg + req * fg * 2e-5) * GCP['lb_gib']
    g['Cloud Armor'] = GCP['armor_politica'] + GCP['armor_regra'] * GCP['armor_regras'] + req * fg / 1e6 * (GCP['armor_req_m'] + GCP['armor_managed_req_m'])
    g['Saída de dados (downloads + réplica p/ AWS)'] = (gb_download * fg + gb_mes * fg) * GCP['egress_gb']
    g['Cloud KMS'] = 2 * GCP['kms_versao'] + (docs * 6 + req * fg) / 1e4 * GCP['kms_10k']
    return a, g


def tabela(lista):
    linhas = []
    for n in lista:
        a, g = custo(n)
        ta, tg = sum(a.values()), sum(g.values())
        linhas.append((n, a, g, ta, tg))
    out = ['| Item | ' + ' | '.join(f'{n} clínicas' for n, *_ in linhas) + ' |', '|---|' + '---:|' * len(linhas)]
    for nuvem, idx in (('AWS', 1), ('GCP', 2)):
        out.append(f'| **{nuvem}** |' + ' |' * len(linhas))
        for item in linhas[0][idx]:
            out.append(f'| {item} | ' + ' | '.join(f'{l[idx][item]:,.2f}' for l in linhas) + ' |')
        out.append(f'| *Subtotal {nuvem}* | ' + ' | '.join(f'*{l[idx + 2]:,.2f}*' for l in linhas) + ' |')
    out.append('| **Total por mês (USD)** | ' + ' | '.join(f'**{l[3] + l[4]:,.2f}**' for l in linhas) + ' |')
    out.append('| Por clínica | ' + ' | '.join(f'{(l[3] + l[4]) / l[0]:,.2f}' for l in linhas) + ' |')
    return '\n'.join(out)


if __name__ == '__main__':
    print(tabela([int(x) for x in sys.argv[1:]] or [20, 100, 3000]))
