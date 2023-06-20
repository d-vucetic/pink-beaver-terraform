resource "aws_lambda_function" "transaction_lambda" {
  function_name    = "transaction_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("transaction_service/lambda_function_payload.zip")
  filename         = "transaction_service/lambda_function_payload.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_dynamodb_table" "transaction_table" {
  name           = "transaction_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
}

resource "aws_sqs_queue" "transaction_queue" {
  name = "transaction_queue"
}

resource "aws_lambda_event_source_mapping" "transaction_event_source_mapping" {
  event_source_arn = aws_sqs_queue.transaction_queue.arn
  function_name    = aws_lambda_function.transaction_lambda.function_name
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_full_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_full_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}