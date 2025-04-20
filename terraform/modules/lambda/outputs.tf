output "function_names" {
  description = "Map of function names"
  value = {
    for key, function in aws_lambda_function.functions :
    key => function.function_name
  }
}

output "function_arns" {
  description = "Map of function ARNs"
  value = {
    for key, function in aws_lambda_function.functions :
    key => function.arn
  }
}

output "alias_arns" {
  description = "Map of function alias ARNs"
  value = {
    for key, alias in aws_lambda_alias.function_aliases :
    key => alias.arn
  }
}

# Nicely structured output for easier reference
output "functions" {
  description = "Complete function information including aliases"
  value = {
    for func_key, func in aws_lambda_function.functions : func_key => {
      name = func.function_name
      arn  = func.arn
      aliases = {
        for alias_key, alias in aws_lambda_alias.function_aliases :
        trimprefix(alias_key, "${func_key}_") => {
          arn     = alias.arn
          name    = alias.name
          version = alias.function_version
        }
        if startswith(alias_key, "${func_key}_")
      }
    }
  }
}
