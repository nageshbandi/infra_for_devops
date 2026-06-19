resource "local_file" "bandi" {
    content  = "Hello, Terraform!"
    filename = "hello_terraform.txt"

}