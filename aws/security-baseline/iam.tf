resource "aws_sns_topic_policy" "alerts" {
  count  = var.enable_detection ? 1 : 0
  arn    = aws_sns_topic.alerts[0].arn
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "EventBridgePublica"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.alerts[0].arn
    }]
  })
}

resource "aws_s3_bucket_policy" "logs" {
  count  = length(aws_s3_bucket.logs)
  bucket = aws_s3_bucket.logs[0].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "SomenteTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [aws_s3_bucket.logs[0].arn, "${aws_s3_bucket.logs[0].arn}/*"]
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
      {
        Sid       = "ServicosDeLogLeemAcl"
        Effect    = "Allow"
        Principal = { Service = ["cloudtrail.amazonaws.com", "config.amazonaws.com", "delivery.logs.amazonaws.com"] }
        Action    = ["s3:GetBucketAcl", "s3:ListBucket"]
        Resource  = aws_s3_bucket.logs[0].arn
      },
      {
        Sid       = "ServicosDeLogEscrevemDaOrganizacao"
        Effect    = "Allow"
        Principal = { Service = ["cloudtrail.amazonaws.com", "config.amazonaws.com", "delivery.logs.amazonaws.com"] }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.logs[0].arn}/*"
        Condition = { StringEquals = { "aws:SourceOrgID" = var.organization_id } }
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.logs]
}
