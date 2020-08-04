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
import Geohash

class DemoManager: NSObject, CLLocationManagerDelegate, ObservableObject, WCSessionDelegate {
	static let INFURA_TOKEN = "44ba7c8772d247b49c57fbc640425f74"
	static let registryAddress = EthereumAddress("0x46E57Bab9298612E0A49DF4048AE20fC2811C4b8")
	static let DEMO_GEOHASH = "c20g0vzfp"
	
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
	@Published var currentImage: UIImage?
	
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
		let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 45.5593, longitude: -122.6514), radius: 50, identifier: "DemoRegion")
		
		locationManager.startMonitoring(for: region)
	}
	
	func registerDemoRegion2() {
		let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 45.5648, longitude: -122.6449), radius: 50, identifier: "DemoRegion2")
		
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
				registerDemoRegion2()
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
		self.currentRegion = nil
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}
		
		print(location.coordinate.geohash(length: 9))
		print(Geohash.bigIntValue(geohash: location.coordinate.geohash(length: 9)))
						
		self.registry.contentIdentifier(tokenContract: DemoManager.registryAddress, geohash: location.coordinate.geohash(length: 9)) { (error, cid) in
			if error != nil {
				print("ERROR: \(error!.localizedDescription)")
				return
			}
			DispatchQueue.main.async {
				self.cid = cid
				self.state = .searchingForContent
			}
			guard let cid = cid, cid.count > 0 else { return }
			
			URLSession.shared.dataTask(with: URL(string: "https://ipfs.io/ipfs/QmbJKNWY7BxWKqD5d7eiRKTgLHJUPeYoJZodqYSkw2TbV2")!) { (data, response, error) in
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
				
				URLSession.shared.dataTask(with: URL(string: "https://ipfs.io/ipfs/\(demoContent.image["/"]!)")!) { (data, response, error) in
					if error != nil {
						print("ERROR: \(error!.localizedDescription)")
						return
					}
					
					DispatchQueue.main.async {
						self.currentImage = UIImage(data: data!)
					}
				}.resume()

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
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		
	}
}
