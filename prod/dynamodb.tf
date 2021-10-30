resource "aws_dynamodb_table" "assets" {
  hash_key         = "assetId"
  name             = "assets"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode     = "PAY_PER_REQUEST"
  point_in_time_recovery {
    enabled = true
  }
  attribute {
    name = "assetId"
    type = "S"
  }
}
