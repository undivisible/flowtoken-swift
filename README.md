# FlowToken Swift

Native SwiftUI animation for streaming LLM output. No dependencies.

## Install

Add FlowToken to your Swift package:

```swift
.package(url: "https://github.com/undivisible/flowtoken-swift.git", from: "0.1.0")
```

Then add `"FlowToken"` to the target dependencies.

## Token streaming

Use `TokenizedText` for plain streamed output. The view preserves whitespace, wraps at its container width, and animates only newly appended tokens.

```swift
import FlowToken
import SwiftUI

struct ReplyView: View {
    let reply: String

    var body: some View {
        TokenizedText(reply, separator: .word, animation: .blurIn)
    }
}
```

`separator` accepts `.diff` (the default, one animation per streamed chunk), `.word`, and `.character`.

## Markdown

Use `AnimatedMarkdown` when SwiftUI's native Markdown rendering is more important than per-token animation:

```swift
AnimatedMarkdown("## Hello, **world**!", animation: .fadeIn)
```

## API

- `TokenizedText(_:separator:animation:animationDuration:)`
- `AnimatedMarkdown(_:animation:animationDuration:)`
- `FlowTokenSeparator`: `.diff`, `.word`, `.character`
- `FlowTokenAnimation`: `.fadeIn`, `.blurIn`, `.dropIn`, `.slideUp`, `.scaleIn`, `.none`

## Development

```bash
swift test
```

## License

ISC
