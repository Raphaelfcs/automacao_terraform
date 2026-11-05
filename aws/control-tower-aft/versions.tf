terraform {
  # O AFT 1.23 exige Terraform >= 1.6.1 e provider AWS 6.x; ele mesmo declara os providers
  # (management, AFT, log archive, audit e região secundária), por isso nada é declarado aqui.
  required_version = ">= 1.7, < 2.0"
}
