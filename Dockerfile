FROM norionomura/swiftlint:swift-5.1
LABEL version="3.1.0"
LABEL repository="https://github.com/norio-nomura/action-swiftlint"
LABEL homepage="https://github.com/norio-nomura/action-swiftlint"
LABEL maintainer="Norio Nomura <norio.nomura@gmail.com>"

LABEL "com.github.actions.name"="GitHub Action for SwiftLint"
LABEL "com.github.actions.description"="A tool to enforce Swift style and conventions."
LABEL "com.github.actions.icon"="shield"
LABEL "com.github.actions.color"="orange"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
