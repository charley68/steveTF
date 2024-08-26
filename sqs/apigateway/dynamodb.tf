resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "url-shortener-table2"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "short_id"

 
  attribute {
    name = "short_id"
    type = "S"
  }

  tags = local.tags
}

# Create a sample TEST entry in dynamo 
resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<ITEM
{
  "short_id": {"S": "bob"},
  "long_url": {"S": "https://www.loveholidays.com/sem/cheap.html?WT.mc_id=pgo-35492155817-aud-1265061430767:kwd-18055111&ch=gen&gad_source=1&gclid=Cj0KCQjwjLGyBhCYARIsAPqTz19Qm2bhdJpOlqJmlDxoUAcQaio8IxpJyBY3AS90D3wyQcaAW6rbzvoaApKjEALw_wcB"}
}
ITEM
}