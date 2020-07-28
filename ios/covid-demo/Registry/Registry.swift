//
//  Registry.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/28/20.
//  Copyright © 2020 Geo Web Project. All rights reserved.
//

import Foundation
import web3

class Registry {
	let client: EthereumClient

	init(client: EthereumClient) {
		self.client = client
	}
	
	func contentIdentifier(tokenContract: EthereumAddress, geohash: Geohash, completion: @escaping((Error?, String?) -> Void)) {
		let function = RegistryFunctions.contentIdentifier(contract: tokenContract, _geohash: geohash.value)
		function.call(withClient: self.client, responseType: RegistryResponses.contentIdentifierResponse.self) { (error, response) in
			return completion(error, response?.value)
		}
	}
}
