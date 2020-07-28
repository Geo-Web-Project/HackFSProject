//
//  RegistryResponses.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/28/20.
//  Copyright © 2020 Geo Web Project. All rights reserved.
//

import Foundation
import web3
import BigInt

enum RegistryResponses {
	struct contentIdentifierResponse: ABIResponse {
        public static var types: [ABIType.Type] = [ String.self ]
        public let value: String
        
        public init?(values: [ABIType]) throws {
            self.value = try values[0].decoded()
        }
    }
}
