import Testing

@testable import FlowToken

@Test func tokenizationPreservesWordsAndCharacters() {
  #expect(Tokenizer.tokens(for: "hello  world", separator: .word) == ["hello", "  ", "world"])
  #expect(Tokenizer.tokens(for: "hi", separator: .character) == ["h", "i"])
  #expect(Tokenizer.tokens(for: "stream", separator: .diff) == ["stream"])
}

@Test func diffStreamingCoalescesDuringAnActiveFade() {
  var accumulator = TokenAccumulator()
  accumulator.update(input: "Hello", separator: .diff)
  accumulator.update(input: "Hello, world", separator: .diff, coalesceActiveDiff: true)
  #expect(accumulator.tokens.map(\.text) == ["Hello, world"])

  accumulator.update(input: "Hello, world again", separator: .diff)
  #expect(accumulator.tokens.map(\.text) == ["Hello, world", " again"])
}
