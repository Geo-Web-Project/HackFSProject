//
//  HostingController.swift
//  watch-demo Extension
//
//  Created by Cody Hatfield on 7/27/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
		return ContentView(state: DemoStateManager.shared)
    }
}
