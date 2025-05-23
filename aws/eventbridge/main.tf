module "eventbridge" {
  source = "gitlab.nexdev.net/iac/aws-eventbridge/aws"
  version = "3.17.1"

  create_bus = false
  #bus_name   = "example" # "default" bus already support schedule_expression in rules

  #attach_lambda_policy = true
  #lambda_target_arns   = [module.lambda_f1.lambda_function_arn]

  schedule_groups = {
    gr = {
      name_prefix = lower("${var.team}-${var.environment}-")
      tags = merge(local.common_tags, {
        Service = "EC2-Scheduler"
        Purpose = "Auto Start/Stop EC2"
      })
    }
  }

  schedules = {
    lambda-start-ec2 = {
      group_name          = "StartEC2Instances"
      description         = "Trigger for Start EC2 instances"
      schedule_expression = "cron(30 7 ? * Mon-Fri *)"
      timezone            = "Asia/Bangkok"
      arn                 = module.lambda_f1.lambda_function_arn
      input               = jsonencode({ "job" : "cron-by-rate" })
    }
    
    lambda-stop-ec2 = {
      group_name          = "StopEC2Instances"
      description         = "Trigger for STOP EC2 instances"
      schedule_expression = "cron(00 20 ? * Mon-Fri *)"
      timezone            = "Asia/Bangkok"
      arn                 = module.lambda_f2.lambda_function_arn
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
  source  = "gitlab.nexdev.net/iac/aws-lambda/aws"
  version = "7.21.0"

  tags = local.common_tags

  function_name = "${var.team}-StartEC2Instances"
  runtime = "python3.9"
  handler       = "StartEC2Instances.lambda_handler"  # Sửa handler để trỏ đến đúng file
  source_path = "${path.module}/fixtures/StartEC2Instances.py"
  build_in_docker = false
  recreate_missing_package = true
  ignore_source_code_hash = false
  local_existing_package = "${path.module}/fixtures/StartEC2Instances.py"
  create_package         = false
  hash_extra = "lambda-package"
}
module "lambda_f2" {
  source  = "gitlab.nexdev.net/iac/aws-lambda/aws"
  version = "7.21.0"

  tags = local.common_tags

  function_name = "${var.team}-StopEC2Instances"
  runtime = "python3.9"
  handler       = "StopEC2Instances.lambda_handler"  # Sửa handler để trỏ đến đúng file
  source_path = "${path.module}/fixtures/StopEC2Instances.py"
  build_in_docker = false
  recreate_missing_package = true
  ignore_source_code_hash = false
  local_existing_package = "${path.module}/fixtures/StopEC2Instances.py"
  create_package         = false
  hash_extra = "lambda-package"
}