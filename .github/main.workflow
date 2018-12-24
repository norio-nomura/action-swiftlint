workflow "New workflow" {
  on = "push"
  resolves = ["Docker Build"]
}

action "swift test" {
  uses = "docker://norionomura/swiftlint:swift-4.2"
  runs = "swift"
  args = "test"
  secrets = ["GITHUB_TOKEN"]
}

action "Docker Lint" {
  uses = "docker://replicated/dockerfilelint"
  args = ["Dockerfile"]
}

action "Docker Build" {
  needs = ["swift test", "Docker Lint"]
  uses = "actions/docker/cli@master"
  args = "build -t action-swiftlint ."
}