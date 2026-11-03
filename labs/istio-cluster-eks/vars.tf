variable "ENV" {
  type        = string
  default     = "qa"
  description = " variavel de ambiente"
}


variable "RANGE_IPS_SR" {
  type        = list(any)
  default     = ["203.0.113.214/32"]
  description = "LISTA DE IPS PARA ACESSO AO CLUSTER"
}

variable "AWS_REGION" {
  type        = string
  default     = "us-west-2"
  description = " zoda de disponibilidade da aws"

}


variable "VPCNAME" {
  type        = string
  default     = "vpc-0123456789abcdef0"
  description = "id da vpc onde o cluster seŕa iniciado."
}


variable "AWS_AMI" {
  type        = string
  default     = "ami-003634241a8fcdec0"
  description = "ami cluster."
}



variable "AWS_TYPE_INSTANCE" {
  type        = string
  default     = "t2.medium"
  description = "tipo de instancia."
}



variable "KEYEC2" {
  type        = string
  default     = "istio"
  description = "chave de acesso as maquinas."
}



variable "SUBNET_EC2" {
  type        = string
  default     = "subnet-0aaa1111bbbb2222c"
  description = "id da subnet."
}



variable "SIZE_VOLUME" {
  type        = string
  default     = 30
  description = "tamanho do volume."
}



variable "TYPE_VOLUME" {
  type        = string
  default     = "gp2"
  description = "propísito do volume na aws."
}




#VARIAVEIS ALB






variable "services_ports" {
  type = list(any)
  default = [
    "22",
    "10250",
    "6443",
    "2379",
    "2380",
    "10250",
    "10255",
    "30000",
    "32767",
    "6783",
    "6784",
    "6783",
    "8060",
    "9090",
    "15000",
    "15004",
    "9093",
    "15010",
    "15014",
    "15030",
    "15090",
    "42422",
    "9080",
    "20001",
    "3000"
  ]
  description = "lista de portas "
}


