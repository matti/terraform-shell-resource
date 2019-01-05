workflow "test" {
  on = "push"
  resolves = ["terraform fmt"]
}

action "terraform fmt" {
  uses = "hashicorp/terraform-github-actions/fmt@v0.1.1"

  env = {
    TF_ACTION_WORKING_DIR = "."
  }

  secrets = ["GITHUB_TOKEN"]
}
