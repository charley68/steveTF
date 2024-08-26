




# Conditionally import the certificate only if it doesn't exist
resource "aws_acm_certificate" "cert" {


  certificate_body = file("./ssl/certificate.crt")
  private_key      = file("./ssl/private.key")
  //certificate_chain = file("ssl/certificate.csr")

  tags = {
    Name = "surepol-cert"
  }

}

