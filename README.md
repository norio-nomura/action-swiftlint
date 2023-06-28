# GitHub Action for SwiftLint

This Action executes [SwiftLint](https://github.com/realm/SwiftLint) and generates annotations from SwiftLint Violations.

## Usage

An example workflow(`.github/workflows/swiftlint.yml`) to executing SwiftLint follows:

```yaml
name: SwiftLint

on:
  pull_request:
    paths:
      - '.github/workflows/swiftlint.yml'
      - '.swiftlint.yml'
      - '**/*.swift'

jobs:
  SwiftLint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v
      - name: GitHub Action for SwiftLint
        uses: Supereg/action-swiftlint@3.2.1
      - name: GitHub Action for SwiftLint with --strict
        uses: Supereg/action-swiftlint@3.2.1
        with:
          args: --strict
      - name: GitHub Action for SwiftLint (Only files changed in the PR)
        uses: Supereg/action-swiftlint@3.2.1
        env:
          DIFF_BASE: ${{ github.base_ref }}
      - name: GitHub Action for SwiftLint (Different working directory)
        uses: Supereg/action-swiftlint@3.2.1
        with:
          working-directory: Source
```

## Secrets

- ~~Specifying `GITHUB_TOKEN` to `secrets` is required to using [Check Run APIs](https://developer.github.com/v3/checks/runs/) for generating annotations from SwiftLint Violations.~~
- Since 3.0.0, `GITHUB_TOKEN` is no longer needed.

## Example
[Here](https://github.com/norio-nomura/test-action-swiftlint/pull/1/files) is an example that actually works.
![screenshot](screenshot.png)

## Author

Norio Nomura

## License

[MIT](LICENSE)
