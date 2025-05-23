module "eventbridge" {
  source = "gitlab.nexdev.net/iac/aws-eventbridge/aws"
  version = "3.17.1"

  #create_bus = true
  #bus_name   = "example" # "default" bus already support schedule_expression in rules

  #attach_lambda_policy = true
  #lambda_target_arns   = [module.lambda.lambda_function_arn]

  schedule_groups = {
    gr = {
      name_prefix = lower("${var.team}-${var.environment}-")
      tags = local.common_tags
    }
  }

  schedules = {
    lambda-cron = {
      group_name          = "gr"
      description         = "Trigger for Start EC2 instances"
      schedule_expression = "cron(0 1 * * ? *)"
      timezone            = "Asia/Bangkok"
      arn                 = module.lambda_f1.lambda_function_arn
      input               = jsonencode({ "job" : "cron-by-rate" })
    }
  }
}

##################
# Extra resources
##################

#############################################
# Using packaged function from Lambda module
#############################################
module "lambda_f1" {
  source = "gitlab.nexdev.net/iac/aws-lambda/aws"
  version = "7.21.0"

  tags = local.common_tags

  function_name = "${var.team}-StartEC2Instances"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  description   = "Trigger for Start EC2 instances"
  trusted_entities = ["scheduler.amazonaws.com"]

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "scheduler.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_schedule_arns["lambda-cron"]
    }
  }
  source_path = "${path.module}/fixtures/StartEC2Instances.py"
}
