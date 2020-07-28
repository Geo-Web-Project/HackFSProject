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
import WatchConnectivity
import web3

class DemoManager: NSObject, CLLocationManagerDelegate, ObservableObject, WCSessionDelegate {
	static let INFURA_TOKEN = "44ba7c8772d247b49c57fbc640425f74"
	static let registryAddress = EthereumAddress("0x46E57Bab9298612E0A49DF4048AE20fC2811C4b8")
	static let DEMO_GEOHASH = Geohash("c20g0vzc")!
	
	let web3Client: EthereumClient
	let registry: Registry
	
	let locationManager: CLLocationManager
	let notificationCenter: UNUserNotificationCenter
	let wcSession: WCSession?
	
	@Published var state: DemoState = .noContent
	@Published var cid: String? = nil
	@Published var currentRegion: DemoModel? {
		didSet {
			if currentRegion == nil {
				self.state = .noContent
				self.wcSession?.transferCurrentComplicationUserInfo([
					"header": "No location found",
					"body": ""
				])
			} else {
				self.state = .contentFound
				self.wcSession?.transferCurrentComplicationUserInfo([
					"header": currentRegion!.name,
					"body": currentRegion!.covidPolicy.masksRequired ? "Masks are required" : "Masks are not required"
				])
			}
		}
	}
	
	override init() {
		locationManager = CLLocationManager()
		notificationCenter = UNUserNotificationCenter.current()
		
		if WCSession.isSupported() {
			self.wcSession = WCSession.default
		} else {
			self.wcSession = nil
		}
		
		let clientUrl = URL(string: "https://rinkeby.infura.io/v3/\(DemoManager.INFURA_TOKEN)")!
		self.web3Client = EthereumClient(url: clientUrl)
		self.registry = Registry(client: self.web3Client)
		
		super.init()
		locationManager.delegate = self
		wcSession?.delegate = self
		
		self.wcSession?.activate()
		
		self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			self.locationManager.requestAlwaysAuthorization()
		}
	}
	
	func registerDemoRegion() {
		let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 45.5593, longitude: -122.6514), radius: 100, identifier: "DemoRegion")
		
		locationManager.startMonitoring(for: region)
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
			if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
				registerDemoRegion()
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
		
		self.state = .searchingForContent
		
		self.registry.contentIdentifier(tokenContract: DemoManager.registryAddress, geohash: Geohash("u4pruydqqvj")!) { (error, cid) in
			if error != nil {
				print("ERROR: \(error!.localizedDescription)")
				return
			}
			DispatchQueue.main.async {
				self.cid = cid
			}
			guard let cid = cid else { return }
			
			URLSession.shared.dataTask(with: URL(string: "https://ipfs.io/ipfs/\(cid)")!) { (data, response, error) in
				if error != nil {
					print("ERROR: \(error!.localizedDescription)")
					return
				}
				
				let decoder = JSONDecoder()
				let demoContent = try! decoder.decode(DemoModel.self, from: data!)
				
				DispatchQueue.main.async {
					self.currentRegion = demoContent
				}
				
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
			}.resume()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("Did exit region: \(region)")
		self.currentRegion = nil
	}
	
//	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		guard let location = locations.first else {
//			return
//		}
//
//
//	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		
	}
}
