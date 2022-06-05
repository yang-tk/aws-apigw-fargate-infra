/*
 * Create a REST API and configured as REGIONAL type for multi-region infrastructure
 * Depends on the use cases can change to Edge Optimized and use
 * Route53 and Health check for latency optimization
 */
resource "aws_api_gateway_rest_api" "main" {
  name = var.name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = var.path_part
}

/*
 * Create an API Key for authentication
 */
resource "aws_api_gateway_api_key" "main" {
  name        = "${var.name}-api-keys"
  description = "API authentication key for ${var.name}"
  enabled     = true
}

/*
 * Provides a HTTP method integration for the API gateway resource
 * For API methods integration, we are using API Gateway Proxy which
 * acts as a gateway between our backend services
 */
resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  type                    = var.integration_input_type
  uri                     = "http://${var.nlb_dns_name}:${var.app_port}/{proxy}"
  integration_http_method = var.integration_http_method

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this.id
}

/*
 * Deploy API gateway to stage (e.g. dev02-us-east-1)
 */
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "${var.stage}-${var.aws_region}"
  depends_on  = [aws_api_gateway_integration.main]

  variables = {
    resources = join(", ", [aws_api_gateway_resource.main.id])
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
 * Create a custom domain name for API gateway and mapping the API gateway to the custom domain
 * Use Route 53 to route traffic to the regional API endpoint
 * The ACM certificate is region specific
 */
resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name             = var.domain_name
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "base_path" {
  api_id      = aws_api_gateway_rest_api.main.id
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
  stage_name  = "${var.stage}-${var.aws_region}"

  depends_on = [
    aws_api_gateway_deployment.main,
    aws_api_gateway_domain_name.custom_domain
  ]
}

resource "aws_route53_record" "main" {
  name    = aws_api_gateway_domain_name.custom_domain.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}

/*
 * Create a API usage plan and attach the API key to the plan
 */
resource "aws_api_gateway_usage_plan" "main" {
  name         = "${var.name}-api-usage-plan"
  description  = "API usage plan for ${var.stage} environment"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = "${var.stage}-${var.aws_region}"
  }

  quota_settings {
    limit  = 1000
    offset = 0
    period = "DAY"
  }

  depends_on = [
    aws_api_gateway_deployment.main
  ]
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id

  depends_on = [aws_api_gateway_usage_plan.main]
}