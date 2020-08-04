//
//  DemoModel.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/28/20.
//  Copyright © 2020 Geo Web Project. All rights reserved.
//

import Foundation

enum DemoState {
	case noContent
	case searchingForContent
	case contentFound
}

struct DemoModel: Codable {
	let name: String
	let image: [String : String]
	let covidPolicy: CovidPolicy
	
	enum CodingKeys : String, CodingKey {
		case name
		case image
		case covidPolicy = "covid-policy"
	}
}

struct CovidPolicy: Codable {
	let summary: String
	let masksRequired: Bool
	
	enum CodingKeys : String, CodingKey {
		case summary
		case masksRequired = "masks-required"
	}
}
