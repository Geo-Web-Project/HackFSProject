//
//  ContentView.swift
//  watch-demo Extension
//
//  Created by Cody Hatfield on 7/27/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var state: DemoStateManager
	
    var body: some View {
		VStack {
			Text(state.header)
			Text(state.body)
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(state: DemoStateManager.shared)
    }
}
