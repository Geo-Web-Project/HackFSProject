//
//  Geohash.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/27/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import Foundation
import BigInt

struct Geohash {
	private static let charmap = Array("0123456789bcdefghjkmnpqrstuvwxyz")
	
	let value: BigUInt
	
	init?(_ str: String) {
		var _value = BigUInt(0)
		for (i, char) in str.reversed().enumerated() {
			guard let v = Geohash.charmap.firstIndex(of: char) else { return nil }
			
			_value += BigUInt(v) * BigUInt(32).power(i)
		}
		
		self.value = _value
	}
}
