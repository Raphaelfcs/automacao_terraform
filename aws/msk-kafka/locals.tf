locals {
  # O MSK exige número de brokers múltiplo do número de subnets (uma por AZ).
  brokers_per_az = max(1, floor(var.broker_count / length(var.subnet_ids)))
  broker_nodes   = local.brokers_per_az * length(var.subnet_ids)
}
