//
//  Geohash.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/27/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import Foundation
import BigInt
import Geohash

extension Geohash {
	static func bigIntValue(geohash: String) -> BigUInt? {
		let charmap = Array("0123456789bcdefghjkmnpqrstuvwxyz")
		
		var _value = BigUInt(0)
		for (i, char) in geohash.reversed().enumerated() {
			guard let v = charmap.firstIndex(of: char) else { return nil }
			
			_value += BigUInt(v) * BigUInt(32).power(i)
		}
		
		return _value
	}
}
