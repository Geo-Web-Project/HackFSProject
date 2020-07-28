//
//  ContentView.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/17/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var manager: DemoManager
	
    var body: some View {
		VStack(spacing: 20.0) {
			if manager.state == .noContent {
				Text("No data found for current location")
			} else if manager.state == .searchingForContent {
				Text("Searching for content...")
			} else {
				Spacer()
				Text("Welcome to \(manager.currentRegion!.name)")
					.font(.system(size: 20.0))
				Text(manager.currentRegion!.covidPolicy.summary)
					.font(.system(size: 16.0))
				Spacer()
				Text("Masks required: \(String(manager.currentRegion!.covidPolicy.masksRequired))")
					.font(.system(size: 16.0))
					.fontWeight(.bold)
				Spacer()
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(manager: DemoManager())
    }
}
