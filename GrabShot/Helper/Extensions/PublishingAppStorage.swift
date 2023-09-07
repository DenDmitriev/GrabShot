//
//  PublishingAppStorage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import SwiftUI
import Combine

/// Property wrapper that acts the same as @AppStorage, but also provides a ``Publisher`` so that non-View types
/// can receive value updates.
@propertyWrapper
struct PublishingAppStorage<Value> {

    var wrappedValue: Value {
        get { storage.wrappedValue }
        set {
            storage.wrappedValue = newValue
            subject.send(storage.wrappedValue)
        }
    }

    var projectedValue: Self {
        self
    }

    /// Provides access to ``AppStorage.projectedValue`` for binding purposes.
    var binding: Binding<Value> {
        storage.projectedValue
    }

    /// Provides a ``Publisher`` for non view code to respond to value updates.
    private let subject = PassthroughSubject<Value, Never>()
    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    private var storage: AppStorage<Value>

    init(wrappedValue: Value, _ key: String) where Value == String {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == Int {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value == Data {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value == Int {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == String {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value == URL {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value == Double {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    init(wrappedValue: Value, _ key: String) where Value == Bool {
        storage = AppStorage(wrappedValue: wrappedValue, key)
    }

    mutating func update() {
        storage.update()
    }
}
