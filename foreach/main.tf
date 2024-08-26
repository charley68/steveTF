variable "instance_set1" {
  type = set(string)
  default = ["Instance A", "Instance B"]
}

variable "instance_set2" {
  type = list
  default = ["Instance C", "Instance D"]
}


resource "aws_instance" "withForEach" {
  for_each = var.instance_set1
  ami = "ami-008ea0202116dbc56"
  instance_type = "t2.micro"

  tags = {
    Name = each.value
  }
}


resource "aws_instance" "withCount" {
  count = 2
  ami = "ami-008ea0202116dbc56"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_set2[count.index]
  }
}
