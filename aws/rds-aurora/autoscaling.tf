# Autoscaling de réplicas de leitura (Aurora Replica) por CPU média.
resource "aws_appautoscaling_target" "replicas" {
  count = var.replica_autoscaling == null ? 0 : 1

  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.this.id}"
  min_capacity       = var.replica_autoscaling.min_capacity
  max_capacity       = var.replica_autoscaling.max_capacity

  depends_on = [aws_rds_cluster_instance.this]
}

resource "aws_appautoscaling_policy" "replicas" {
  count = var.replica_autoscaling == null ? 0 : 1

  name               = "${var.name}-replicas-cpu"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.replicas[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.replicas[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.replicas[0].resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = var.replica_autoscaling.target_cpu
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
