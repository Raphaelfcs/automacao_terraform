# Permissão mínima: a API invoca a função só pelas rotas deste stage.
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowHttpApi-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
