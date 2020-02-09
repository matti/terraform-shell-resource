module "files" {
  source  = "../.."
  command = "ls -l"
}

output "my_files" {
  value = module.files.stdout
}
