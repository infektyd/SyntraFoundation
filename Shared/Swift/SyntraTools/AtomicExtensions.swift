// AtomicExtensions.swift
// SyntraFoundation
//
// Created by SyntraFoundation on 8/15/25.
//

import Atomics
#if canImport(_AtomicsShims)
// Avoid using @_implementationOnly import; rely on Atomics public API or local shims if needed.
#endif
import AsyncAlgorithms

extension ManagedAtomic where Value: AtomicInteger {
    /// Atomically increments the value and returns the new value
    @inlinable
    public func increment(by amount: Value = 1) -> Value {
        self.wrappingIncrement(by: amount, ordering: .acquiringAndReleasing)
        return self.load(ordering: .relaxed)
    }
    
    /// Atomically decrements the value and returns the new value
    @inlinable
    public func decrement(by amount: Value = 1) -> Value {
        self.wrappingDecrement(by: amount, ordering: .acquiringAndReleasing)
        return self.load(ordering: .relaxed)
    }
}

extension ManagedAtomic where Value == Bool {
    /// Atomically toggles the boolean value and returns the new value
    @inlinable
    public func toggle() -> Value {
        return self.exchange(!self.load(ordering: .relaxed), ordering: .acquiringAndReleasing)
    }
}

extension UnsafeAtomic where Value: AtomicInteger {
    /// Atomically increments the value and returns the new value
    @inlinable
    public func increment(by amount: Value = 1) -> Value {
        self.wrappingIncrement(by: amount, ordering: .acquiringAndReleasing)
        return self.load(ordering: .relaxed)
    }
    
    /// Atomically decrements the value and returns the new value
    @inlinable
    public func decrement(by amount: Value = 1) -> Value {
        self.wrappingDecrement(by: amount, ordering: .acquiringAndReleasing)
        return self.load(ordering: .relaxed)
    }
}

extension UnsafeAtomic where Value == Bool {
    /// Atomically toggles the boolean value and returns the new value
    @inlinable
    public func toggle() -> Value {
        return self.exchange(!self.load(ordering: .relaxed), ordering: .acquiringAndReleasing)
    }
}

/// Async-safe atomic operations using AsyncChannel
public actor AsyncAtomic<T: Sendable> {
    private let channel: AsyncChannel<T>
    private var value: T
    
    public init(_ initialValue: T) {
        self.value = initialValue
        self.channel = AsyncChannel()
    }
    
    /// Get the current value
    public func get() -> T {
        return value
    }
    
    /// Set a new value and notify all listeners
    public func set(_ newValue: T) async {
        value = newValue
        await channel.send(newValue)
    }
    
    /// Wait for and return the next value update
    public func next() async -> T {
        for await value in channel {
            return value
        }
        return value
    }
    
    /// Perform an atomic update operation
    public func update(_ transform: (T) -> T) async {
        let newValue = transform(value)
        await set(newValue)
    }
}
