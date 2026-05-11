import Foundation

enum Logger {
    #if DEBUG
    static func info(_ message: String, category: String = "APP") {
        print("[\(category)] ℹ️ \(message)")
    }

    static func debug(_ message: String, category: String = "APP") {
        print("[\(category)] 🐛 \(message)")
    }

    static func warning(_ message: String, category: String = "APP") {
        print("[\(category)] ⚠️ \(message)")
    }
    #else
    static func info(_ message: String, category: String = "APP") { }
    static func debug(_ message: String, category: String = "APP") { }
    static func warning(_ message: String, category: String = "APP") { }
    #endif

    static func error(_ message: String, category: String = "APP") {
        print("[\(category)] ❌ \(message)")
    }
}
