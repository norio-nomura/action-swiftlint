workflow "New workflow" {
  on = "push"
  resolves = ["swift-4.2"]
}

action "swift-4.2" {
  uses = "docker://norionomura/swiftlint:swift-4.2"
  runs = "swift"
  args = "test"
}
