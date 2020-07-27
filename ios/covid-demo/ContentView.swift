//
//  ContentView.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/17/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	let manager: DemoManager?
	
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(manager: nil)
    }
}
