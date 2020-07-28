//
//  DemoStateManager.swift
//  watch-demo Extension
//
//  Created by Cody Hatfield on 7/28/20.
//  Copyright © 2020 Geo Web Project. All rights reserved.
//

import Foundation

class DemoStateManager: ObservableObject {
	static let shared = DemoStateManager()
	
	@Published var header: String = "No location found"
	@Published var body: String = ""
}
