# GitHub Action for SwiftLint

This Action executes [SwiftLint](https://github.com/realm/SwiftLint) and generates annotations from SwiftLint Violations by using [GitHub Checks API](https://blog.github.com/2018-05-07-introducing-checks-api/).

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
      - uses: actions/checkout@v1
      - name: GitHub Action for SwiftLint
        # Avoid failing with "server error status: 403" on PR from forked repository
        if: github.event.pull_request.base.repo.id == github.event.pull_request.head.repo.id
        uses: norio-nomura/action-swiftlint@2.2.0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Secrets

- Specifying `GITHUB_TOKEN` to `secrets` is required to using [Check Run APIs](https://developer.github.com/v3/checks/runs/) for generating annotations from SwiftLint Violations.

## Example
[Here](https://github.com/norio-nomura/test-action-swiftlint/pull/1/files#annotation_9749095) is an example that actually works.
![screenshot](screenshot.png)

## Author

Norio Nomura

## License

[MIT](LICENSE)
