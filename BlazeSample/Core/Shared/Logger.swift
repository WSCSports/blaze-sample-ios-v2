//
//  LogLevel.swift
//  blaze-sample-ios-v2
//
//  Created by Max Lukashevich on 29/06/2025.
//

import Foundation

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self._encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

enum LogLevel: String {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case debug = "🐞 DEBUG"
}

final class Logger {

    static let shared = Logger()

    private let logQueue = DispatchQueue(label: "com.yourapp.logger.queue", qos: .utility)

    private init() {}

    private func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    func log(
        _ message: String,
        object: Any? = nil,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logQueue.async {
            let timestamp = self.formattedTimestamp()
            let fileName = (file as NSString).lastPathComponent

            var logMessage = """
            Blaze Sample:
            [\(timestamp)] [\(level.rawValue)]
            ⤷ File: \(fileName)
            ⤷ Func: \(function) [Line: \(line)]
            ⤷ Msg : \(message)
            """

            if let obj = object {
                logMessage += "\n↳ Object:\n\(self.describe(obj))"
            }

            print(logMessage + "\n")
        }
    }

    private func describe(_ object: Any) -> String {
        // Try pretty-printing Encodable as JSON
        if let encodable = object as? Encodable,
           let json = try? JSONEncoder.pretty.encode(AnyEncodable(encodable)),
           let jsonString = String(data: json, encoding: .utf8) {
            return jsonString
        }

        return mirrorDescription(object)
    }

    private func mirrorDescription(_ value: Any, indent: String = "") -> String {
        let mirror = Mirror(reflecting: value)
        var result = "\(type(of: value)) {\n"

        for child in mirror.children {
            guard let label = child.label else { continue }
            let childValue = child.value

            if Mirror(reflecting: childValue).children.isEmpty {
                result += "\(indent)  \(label): \(childValue)\n"
            } else {
                result += "\(indent)  \(label): \(mirrorDescription(childValue, indent: indent + "  "))\n"
            }
        }

        result += "\(indent)}"
        return result
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
