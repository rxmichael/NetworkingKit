//
//  RequestParameters.swift
//  
//
//  Created by Michael Eid on 4/26/24.
//

import Foundation

public enum RequestParameters {
    case body(Parameters)
    case query(Parameters)
    case data(Data)
    case none
}

public typealias Parameters = [String : ParameterValueType]

public protocol ParameterValueType {
    var value: String { get }
}

extension Int: ParameterValueType {
    public var value: String { String(self) }
}

extension UInt: ParameterValueType {
    public var value: String { String(self) }
}

extension Int64: ParameterValueType {
    public var value: String { String(self) }
}

extension Array: ParameterValueType where Element: ParameterValueType {
    public var value: String { map(\.value).joined(separator: ",") }
}

extension String: ParameterValueType {
    public var value: String { self }
}

extension Double: ParameterValueType {
    public var value: String { String(self) }
}

extension Bool: ParameterValueType {
    public var value: String { self ? "true" : "false" }
}

extension Date: ParameterValueType {
    public var value: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

extension Dictionary: ParameterValueType where Key: Encodable, Value: Encodable {
    public var value: String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return ""
    }
}
