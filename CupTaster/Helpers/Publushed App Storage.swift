//
//  Publushed App Storage.swift
//  CupTaster
//
//  Created by Nikita on 12.02.2024.
//

import SwiftUI
import Combine

@propertyWrapper
public struct PublishedAppStorage<Value> {
    @AppStorage private var storedValue: Value
    
    private var publisher: Publisher?
    internal var objectWillChange: ObservableObjectPublisher?
    
    public struct Publisher: Combine.Publisher {
        
        public typealias Output = Value
        
        public typealias Failure = Never
        
        public func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Downstream.Input == Value, Downstream.Failure == Never {
            subject.subscribe(subscriber)
        }
        
        fileprivate let subject: Combine.CurrentValueSubject<Value, Never>
        
        fileprivate init(_ output: Output) {
            subject = .init(output)
        }
    }

    public var projectedValue: Publisher {
        mutating get {
            if let publisher = publisher {
                return publisher
            }
            let publisher = Publisher(storedValue)
            self.publisher = publisher
            return publisher
        }
    }
    
    @available(*, unavailable, message: "@Published is only available on properties of classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedAppStorage<Value>>
    ) -> Value {
        get {
            object[keyPath: storageKeyPath].storedValue
        }
        set {
            (object.objectWillChange as? ObservableObjectPublisher)?.send()
            object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
            object[keyPath: storageKeyPath].storedValue = newValue
        }
    }
    
    // MARK: - Initializers

    // RawRepresentable
    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }
    
    // String
    init(wrappedValue: String, _ key: String, store: UserDefaults? = nil) where Value == String {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }

    // Data
    init(wrappedValue: Data, _ key: String, store: UserDefaults? = nil) where Value == Data {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }
    
    // Int
    init(wrappedValue: Int, _ key: String, store: UserDefaults? = nil) where Value == Int {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }
    
    // URL
    init(wrappedValue: URL, _ key: String, store: UserDefaults? = nil) where Value == URL {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }
    
    // Double
    init(wrappedValue: Double, _ key: String, store: UserDefaults? = nil) where Value == Double {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }

    // Bool
    init(wrappedValue: Bool, _ key: String, store: UserDefaults? = nil) where Value == Bool {
        self._storedValue = AppStorage(wrappedValue: wrappedValue, key, store: store)
    }
}
