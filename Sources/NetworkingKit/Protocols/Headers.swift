//
//  Headers.swift
//
//
//  Created by Michael Eid on 4/26/24.
//

import Foundation

public typealias Headers = [String: String]

extension Headers {
    static let `default` = [
        "Content-Type": "application/json",
        "Accept": "application/json"]
}
