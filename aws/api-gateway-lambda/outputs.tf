output "api_id" {
  description = "ID da API."
  value       = aws_apigatewayv2_api.this.id
}

output "invoke_url" {
  description = "URL de invocação do stage."
  value       = aws_apigatewayv2_stage.this.invoke_url
}
