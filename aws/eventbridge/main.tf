module "eventbridge" {
  source  = "gitlab.nexdev.net/iac/aws-eventbridge/aws"
  version = "3.17.1"

  create_bus = false
  tags       = local.common_tags
  #bus_name   = "example" # "default" bus already support schedule_expression in rules

  attach_policy_statements = true
  policy_statements = {
    lambda = {
      effect = "Allow",
      actions = ["lambda:InvokeFunction"],
      resources = [
        module.lambda_f1.lambda_function_arn,
        module.lambda_f2.lambda_function_arn
      ]
    }
  }
  schedule_groups = {
    gr = {
      name = lower("${var.team}-${var.environment}-EC2Instances")
      tags = merge(local.common_tags, {
        Service = "EC2-Scheduler"
        Purpose = "Auto Start/Stop EC2"
      })
    }
  }

  schedules = {
    lambda-start-ec2 = {
      group_name          = lower("${var.team}-${var.environment}-EC2Instances")
      description         = "Trigger for Start EC2 instances"
      schedule_expression = "cron(35 10 ? * Mon-Fri *)"
      timezone            = "Asia/Bangkok"
      arn                 = module.lambda_f1.lambda_function_arn
      input               = jsonencode({ "job" : "cron-by-rate" })
    }

    lambda-stop-ec2 = {
      group_name          = lower("${var.team}-${var.environment}-EC2Instances")
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
  source                                  = "gitlab.nexdev.net/iac/aws-lambda/aws"
  version                                 = "7.21.0"
  tags                                    = local.common_tags
  function_name                           = "${var.team}-StartEC2Instances"
  runtime                                 = "python3.9"
  handler                                 = "StartEC2Instances.lambda_handler"
  local_existing_package                  = "${path.module}/fixtures/StartEC2Instances.zip"
  trusted_entities                        = ["scheduler.amazonaws.com"]
  create_package                          = false
  create_current_version_allowed_triggers = false
  attach_cloudwatch_logs_policy = true
  cloudwatch_logs_retention_in_days = 7
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "scheduler.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_schedule_arns["lambda-start-ec2"]
    }
  }
  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow",
      actions = [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      resources = ["*"]
    },
    scheduler = {
      effect = "Allow",
      actions = ["scheduler:InvokeSchedule"],
      resources = ["*"]
    }
  }
}

module "lambda_f2" {
  source                                  = "gitlab.nexdev.net/iac/aws-lambda/aws"
  version                                 = "7.21.0"
  tags                                    = local.common_tags
  function_name                           = "${var.team}-StopEC2Instances"
  runtime                                 = "python3.9"
  handler                                 = "StopEC2Instances.lambda_handler"
  local_existing_package                  = "${path.module}/fixtures/StopEC2Instances.zip"
  trusted_entities                        = ["scheduler.amazonaws.com"]
  create_package                          = false
  create_current_version_allowed_triggers = false
  attach_cloudwatch_logs_policy = true
  cloudwatch_logs_retention_in_days = 7
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "scheduler.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_schedule_arns["lambda-stop-ec2"]
    }
  }
  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow",
      actions = [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      resources = ["*"]
    },
    scheduler = {
      effect = "Allow",
      actions = ["scheduler:InvokeSchedule"],
      resources = ["*"]
    }
  }
}