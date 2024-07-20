# resource "aws_kms_key" "cloudwatch_key" {
#   description         = "cloudwatch key for vpc flow logs"
#   policy              = data.aws_iam_policy_document.cloudwatch_key.json
#   enable_key_rotation = true
# }

# resource "aws_kms_alias" "cloudwatch_key_alias" {
#   name          = "alias/flowlogs-cloudwatch-cmk"
#   target_key_id = aws_kms_key.cloudwatch_key.key_id
# }