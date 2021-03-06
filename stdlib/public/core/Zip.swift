//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A sequence of pairs built out of two underlying sequences, where
/// the elements of the `i`th pair are the `i`th elements of each
/// underlying sequence.
public func zip<Sequence1 : SequenceType, Sequence2 : SequenceType>(
  sequence1: Sequence1, _ sequence2: Sequence2
) -> Zip2Sequence<Sequence1, Sequence2> {
  return Zip2Sequence(sequence1, sequence2)
}

/// A generator for `Zip2Sequence`.
public struct Zip2Generator<
  Generator1 : GeneratorType, Generator2 : GeneratorType
> : GeneratorType {
  /// The type of element returned by `next()`.
  public typealias Element = (Generator1.Element, Generator2.Element)

  /// Construct around a pair of underlying generators.
  public init(_ generator1: Generator1, _ generator2: Generator2) {
    (_baseStream1, _baseStream2) = (generator1, generator2)
  }

  /// Advance to the next element and return it, or `nil` if no next
  /// element exists.
  ///
  /// - Requires: `next()` has not been applied to a copy of `self`
  ///   since the copy was made, and no preceding call to `self.next()`
  ///   has returned `nil`.
  public mutating func next() -> Element? {
    // The next() function needs to track if it has reached the end. If we
    // didn't, and the first sequence is longer than the second, then when we
    // have already exhausted the second sequence, on every subsequent call to
    // next() we would consume and discard one additional element from the
    // first sequence, even though next() had already returned nil.

    if _reachedEnd {
      return nil
    }

    guard let element1 = _baseStream1.next(), element2 = _baseStream2.next() else {
      _reachedEnd = true
      return nil
    }

    return (element1, element2)
  }

  internal var _baseStream1: Generator1
  internal var _baseStream2: Generator2
  internal var _reachedEnd: Bool = false
}

/// A sequence of pairs built out of two underlying sequences, where
/// the elements of the `i`th pair are the `i`th elements of each
/// underlying sequence.
public struct Zip2Sequence<Sequence1 : SequenceType, Sequence2 : SequenceType>
  : SequenceType {

  public typealias Stream1 = Sequence1.Generator
  public typealias Stream2 = Sequence2.Generator

  /// A type whose instances can produce the elements of this
  /// sequence, in order.
  public typealias Generator = Zip2Generator<Stream1, Stream2>

  /// Construct an instance that makes pairs of elements from `sequence1` and
  /// `sequence2`.
  public init(_ sequence1: Sequence1, _ sequence2: Sequence2) {
    (_sequence1, _sequence2) = (sequence1, sequence2)
  }

  /// Returns a generator over the elements of this sequence.
  ///
  /// - Complexity: O(1).
  public func generate() -> Generator {
    return Generator(
      _sequence1.generate(),
      _sequence2.generate())
  }

  internal let _sequence1: Sequence1
  internal let _sequence2: Sequence2
}

@available(*, unavailable, renamed="Zip2Generator")
public struct ZipGenerator2<
  Generator1 : GeneratorType, Generator2 : GeneratorType
> {}

@available(*, unavailable, renamed="Zip2Sequence")
public struct Zip2<
  Sequence1 : SequenceType, Sequence2 : SequenceType
> {}

