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
		let beaconRegion = CLBeaconRegion(uuid: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "DemoBeacon")
		
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
		self.locationManager.requestLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("Did exit region: \(region)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}
		
		IpfsLiteApi.instance().getNodeForCid("QmY9cxiHqTFoWamkQVkpmmqzBrY3hCBEL2XNu3NtX74Fuu") { (node, error) in
			if error != nil {
				print("ERROR: \(error?.localizedDescription)")
				return
			}
			let data = String(data: node!.block.rawData, encoding: .utf8)!
			
			let content = UNMutableNotificationContent()
			content.title = "Did Enter Region"
			content.body = data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

			let uuidString = UUID().uuidString
			let request = UNNotificationRequest(identifier: uuidString,
						content: content, trigger: nil)

			self.notificationCenter.add(request) { (error) in
			   if error != nil {

			   }
			}
		}
	}
}
