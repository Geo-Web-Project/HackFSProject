//
//  RegistryFunctions.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/28/20.
//  Copyright © 2020 Geo Web Project. All rights reserved.
//

import Foundation
import web3
import BigInt

enum RegistryFunctions {
	public struct contentIdentifier: ABIFunction {
        public static let name = "contentIdentifier"
        public let gasPrice: BigUInt?
        public let gasLimit: BigUInt?
        public var contract: EthereumAddress
        public let from: EthereumAddress?
		
		public let _geohash: BigUInt
        
        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    gasPrice: BigUInt? = nil,
                    gasLimit: BigUInt? = nil,
					_geohash: BigUInt) {
            self.contract = contract
            self.from = from
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
			
			self._geohash = _geohash
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(_geohash)
		}
    }
}
