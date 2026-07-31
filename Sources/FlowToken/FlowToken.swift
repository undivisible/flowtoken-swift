import SwiftUI

public enum FlowTokenSeparator: Sendable, Equatable {
  case diff
  case word
  case character
}

public enum FlowTokenAnimation: Sendable, Equatable {
  case fadeIn
  case blurIn
  case dropIn
  case slideUp
  case scaleIn
  case none

  var transition: AnyTransition {
    switch self {
    case .fadeIn:
      .opacity
    case .blurIn:
      .opacity.combined(with: .scale(scale: 0.98))
    case .dropIn:
      .opacity.combined(with: .move(edge: .top))
    case .slideUp:
      .opacity.combined(with: .move(edge: .bottom))
    case .scaleIn:
      .opacity.combined(with: .scale(scale: 0.92))
    case .none:
      .identity
    }
  }
}

public struct TokenizedText: View {
  public let input: String
  public let separator: FlowTokenSeparator
  public let animation: FlowTokenAnimation
  public let animationDuration: TimeInterval

  @State private var accumulator = TokenAccumulator()

  public init(
    _ input: String,
    separator: FlowTokenSeparator = .diff,
    animation: FlowTokenAnimation = .fadeIn,
    animationDuration: TimeInterval = 0.45
  ) {
    self.input = input
    self.separator = separator
    self.animation = animation
    self.animationDuration = animationDuration
  }

  public var body: some View {
    FlowTokenWrapLayout {
      ForEach(accumulator.tokens) { token in
        Text(token.text)
          .fixedSize()
          .transition(animation.transition)
      }
    }
    .animation(
      animation == .none ? nil : .easeInOut(duration: animationDuration),
      value: accumulator.tokens
    )
    .onAppear { updateTokens() }
    .onChange(of: input) { _ in updateTokens() }
  }

  private func updateTokens() {
    accumulator.update(input: input, separator: separator)
  }
}

public struct AnimatedMarkdown: View {
  public let content: String
  public let animation: FlowTokenAnimation
  public let animationDuration: TimeInterval

  @State private var visible = false

  public init(
    _ content: String,
    animation: FlowTokenAnimation = .fadeIn,
    animationDuration: TimeInterval = 0.45
  ) {
    self.content = content
    self.animation = animation
    self.animationDuration = animationDuration
  }

  public var body: some View {
    Text((try? AttributedString(markdown: content)) ?? AttributedString(content))
      .opacity(animation == .none || visible ? 1 : 0)
      .offset(y: animation == .slideUp && !visible ? 8 : 0)
      .scaleEffect(animation == .scaleIn && !visible ? 0.92 : 1)
      .blur(radius: animation == .blurIn && !visible ? 3 : 0)
      .onAppear { reveal() }
      .onChange(of: content) { _ in reveal() }
  }

  private func reveal() {
    visible = false
    withAnimation(animation == .none ? nil : .easeInOut(duration: animationDuration)) {
      visible = true
    }
  }
}

struct Token: Identifiable, Equatable {
  let id: UUID
  let text: String
}

struct TokenAccumulator {
  private(set) var tokens: [Token] = []

  mutating func update(input: String, separator: FlowTokenSeparator) {
    if separator == .diff {
      let assembled = tokens.map(\.text).joined()
      guard input.hasPrefix(assembled) else {
        tokens = input.isEmpty ? [] : [Token(id: UUID(), text: input)]
        return
      }
      let addition = String(input.dropFirst(assembled.count))
      if !addition.isEmpty {
        tokens.append(Token(id: UUID(), text: addition))
      }
      return
    }

    let next = Tokenizer.tokens(for: input, separator: separator)
    let comparedCount = min(tokens.count, next.count)
    let stableCount =
      (0..<comparedCount).first(where: { tokens[$0].text != next[$0] }) ?? comparedCount
    tokens = next.enumerated().map { index, text in
      Token(id: index < stableCount ? tokens[index].id : UUID(), text: text)
    }
  }
}

enum Tokenizer {
  static func tokens(for input: String, separator: FlowTokenSeparator) -> [String] {
    switch separator {
    case .diff:
      return input.isEmpty ? [] : [input]
    case .word:
      var result: [String] = []
      var token = ""
      var isWhitespace: Bool?
      for character in input {
        let nextIsWhitespace = character.isWhitespace
        if let isWhitespace, isWhitespace != nextIsWhitespace {
          result.append(token)
          token = ""
        }
        token.append(character)
        isWhitespace = nextIsWhitespace
      }
      if !token.isEmpty {
        result.append(token)
      }
      return result
    case .character:
      return input.map(String.init)
    }
  }
}

private struct FlowTokenWrapLayout: Layout {
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let width = proposal.width ?? .greatestFiniteMagnitude
    var lineWidth: CGFloat = 0
    var lineHeight: CGFloat = 0
    var result = CGSize.zero

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if lineWidth > 0, lineWidth + size.width > width {
        result.width = max(result.width, lineWidth)
        result.height += lineHeight
        lineWidth = 0
        lineHeight = 0
      }
      lineWidth += size.width
      lineHeight = max(lineHeight, size.height)
    }
    result.width = max(result.width, lineWidth)
    result.height += lineHeight
    return result
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    var point = bounds.origin
    var lineHeight: CGFloat = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if point.x > bounds.minX, point.x + size.width > bounds.maxX {
        point.x = bounds.minX
        point.y += lineHeight
        lineHeight = 0
      }
      subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
      point.x += size.width
      lineHeight = max(lineHeight, size.height)
    }
  }
}
