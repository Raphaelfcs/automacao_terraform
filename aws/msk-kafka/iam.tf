# Política gerenciada para produtores/consumidores via SASL/IAM. Anexe às roles (IRSA,
# Pod Identity ou instância) dos clientes. Escopo: este cluster, tópicos e grupos com prefixo.
data "aws_iam_policy_document" "client" {
  statement {
    sid       = "Cluster"
    actions   = ["kafka-cluster:Connect", "kafka-cluster:DescribeCluster"]
    resources = [aws_msk_cluster.this.arn]
  }

  statement {
    sid = "Topics"
    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:ReadData",
      "kafka-cluster:WriteData",
    ]
    resources = ["arn:aws:kafka:*:*:topic/${aws_msk_cluster.this.cluster_name}/${aws_msk_cluster.this.cluster_uuid}/${var.client_topic_prefix}*"]
  }

  statement {
    sid       = "Groups"
    actions   = ["kafka-cluster:AlterGroup", "kafka-cluster:DescribeGroup"]
    resources = ["arn:aws:kafka:*:*:group/${aws_msk_cluster.this.cluster_name}/${aws_msk_cluster.this.cluster_uuid}/${var.client_topic_prefix}*"]
  }
}

resource "aws_iam_policy" "client" {
  name        = "${var.name_prefix}-msk-client"
  description = "Produzir/consumir no MSK ${var.name_prefix} via SASL/IAM"
  policy      = data.aws_iam_policy_document.client.json
  tags        = var.tags
}
