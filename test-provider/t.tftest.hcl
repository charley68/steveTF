run "example_test" {
 command = plan

 // Define any variables required for your test
 variables {
   example_variable = "value"
 }

 // Assertions to validate the test outcome
 assert {
   condition     = example_resource.attribute == var.example_variable
   error_message = "Test failed: the attribute value was not as expected."
 }

}


