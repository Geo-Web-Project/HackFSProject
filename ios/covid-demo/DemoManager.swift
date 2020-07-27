//
//  DemoManager.swift
//  covid-demo
//
//  Created by Cody Hatfield on 7/17/20.
//  Copyright © 2020 Geo Web Projecy. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import IpfsLiteApi

class DemoManager: NSObject, CLLocationManagerDelegate, ObservableObject {
	static let BLE_DEMO_ID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
	static let DEMO_GEOHASH = Geohash("u4pruydqqvj")!
	
	let locationManager: CLLocationManager
	let notificationCenter: UNUserNotificationCenter
	
	override init() {
		locationManager = CLLocationManager()
		notificationCenter = UNUserNotificationCenter.current()
		
		super.init()
		locationManager.delegate = self
		
		self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			self.locationManager.requestAlwaysAuthorization()
		}
		
		setupIpfsNode()
	}
	
	func registerDemoBeacon() {
		let beaconRegion = CLBeaconRegion(uuid: DemoManager.BLE_DEMO_ID, identifier: "DemoBeacon")
		
		locationManager.startMonitoring(for: beaconRegion)
	}
	
	func setupIpfsNode() {
		let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let repoPath = documents.appendingPathComponent("ipfs-lite")
		
		try! IpfsLiteApi.launch(repoPath.path, debug: false, lowMem: true)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("ERROR: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("MONITORING ERROR: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		print("AUTHORIZATION STATUS CHANGE: \(status.rawValue)")
		switch status {
		case .authorizedAlways:
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				registerDemoBeacon()
			}
		default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		print("Started monitoring: \(region)")
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		print("Did enter region: \(region)")
//		self.locationManager.requestLocation()

		IpfsLiteApi.instance().getNodeForCid("QmXEJHJXHio34DV9gzB8tV2JeqnSTvixjXh7SEJnr2Q9MG") { (node, error) in
			if error != nil {
				print("ERROR: \(error!.localizedDescription)")
				return
			}
			
			// API seems to return a raw protobuf block. Fetching a block that is not protobuf causes an error
			let jsonString = String(data: node!.block.rawData, encoding: .ascii)!.dropFirst(8).dropLast(3)
			
			let decoder = JSONDecoder()
			let demoContent = try! decoder.decode(DemoModel.self, from: jsonString.data(using: .utf8)!)
			
			let content = UNMutableNotificationContent()
			content.title = "Welcome to \(demoContent.name)"
			content.body = demoContent.covidPolicy.summary

			let uuidString = UUID().uuidString
			let request = UNNotificationRequest(identifier: uuidString,
						content: content, trigger: nil)

			self.notificationCenter.add(request) { (error) in
			   if error != nil {

			   }
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("Did exit region: \(region)")
	}
	
//	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		guard let location = locations.first else {
//			return
//		}
//
//
//	}
}

struct DemoModel: Codable {
	let name: String
	let covidPolicy: CovidPolicy
	
	enum CodingKeys : String, CodingKey {
		case name
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
