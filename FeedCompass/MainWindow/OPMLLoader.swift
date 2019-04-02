//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSParser
import RSWeb

public extension Notification.Name {
	static let OPMLDidLoad = Notification.Name(rawValue: "OPMLDidLoad")
	static let UserDidAddOPML = Notification.Name(rawValue: "UserDidAddOPML")
}

final class OPMLLoader {
	
	static var shared = { OPMLLoader() }()
	
	struct UserInfoKey {
		public static let opmlDocument = "opmlDocument" // OPMLDidDownload
	}

	private struct OPMLLocation: Hashable {
		let title: String?
		let url: String
		let userDefined: Bool
	}

	private lazy var downloadSession: DownloadSession = {
		return DownloadSession(delegate: self)
	}()
	
	var progress: DownloadProgress {
		return downloadSession.progress
	}
	
	func load() {
		
		let plist = Bundle.main.path(forResource: "OPML", ofType: "plist")!
		let opml = NSArray(contentsOfFile: plist)! as! [[String: Any]]
		
		var opmlLocations = opml.compactMap( { dict in
			return OPMLLocation(title: dict["title"] as? String, url: dict["url"] as! String, userDefined: false)
		} )
		
		if let userURLs = AppDefaults.userSubscriptions {
			for userURL in userURLs {
				opmlLocations.append(OPMLLocation(title: nil, url: userURL, userDefined: true))
			}
		}
		
		downloadSession.downloadObjects(Set(opmlLocations) as NSSet)
		
	}
	
	func loadUserDefined(url: String) {
		
		guard let downloadURL = URL(string: url) else {
			return
		}
		
		download(downloadURL) { (data: Data?, response: URLResponse?, error: Error?) in
			
			guard let url = response?.url?.absoluteString, let data = data else {
				let error = NSLocalizedString("OPML Not Found", comment: "OPML Not Found")
				NSApplication.shared.presentError(error)
				return
			}
			
			let parserData = ParserData(url: url, data: data)
			if let opmlDocument = try? RSOPMLParser.parseOPML(with: parserData) {
				var userInfo = [String: Any]()
				userInfo[OPMLLoader.UserInfoKey.opmlDocument] = opmlDocument
				NotificationCenter.default.post(name: .UserDidAddOPML, object: nil, userInfo: userInfo)
			} else {
				let error = NSLocalizedString("Invalid OPML Format", comment: "Invalid OPML Format")
				NSApplication.shared.presentError(error)
				return
			}
			
		}
		
	}
	
	func loadLocal(url: URL) {
		
		guard let data = try? Data(contentsOf: url) else {
			return
		}
		
		let parserData = ParserData(url: url.absoluteString, data: data)
		if let opmlDocument = try? RSOPMLParser.parseOPML(with: parserData) {
			
			var userInfo = [String: Any]()
			userInfo[OPMLLoader.UserInfoKey.opmlDocument] = opmlDocument
			NotificationCenter.default.post(name: .UserDidAddOPML, object: self, userInfo: userInfo)

		}

	}
	
}

// MARK: - DownloadSessionDelegate

extension OPMLLoader: DownloadSessionDelegate {
	
	func downloadSession(_ downloadSession: DownloadSession, requestForRepresentedObject representedObject: AnyObject) -> URLRequest? {
		
		guard let opmlLocation = representedObject as? OPMLLocation else {
			return nil
		}
		
		guard let url = URL(string: opmlLocation.url) else {
			return nil
		}
		
		return URLRequest(url: url)
	}
	
	func downloadSession(_ downloadSession: DownloadSession, downloadDidCompleteForRepresentedObject representedObject: AnyObject, response: URLResponse?, data: Data, error: NSError?) {
		
		guard let opmlLocation = representedObject as? OPMLLocation, !data.isEmpty else {
			return
		}
		
		if let error = error {
			print("Error downloading \(opmlLocation.url) - \(error)")
			return
		}
		
		let parserData = ParserData(url: opmlLocation.url, data: data)
		if let opmlDocument = try? RSOPMLParser.parseOPML(with: parserData) {
			
			if opmlLocation.title != nil {
				opmlDocument.title = opmlLocation.title
			}
			
			var userInfo = [String: Any]()
			userInfo[OPMLLoader.UserInfoKey.opmlDocument] = opmlDocument
			NotificationCenter.default.post(name: .OPMLDidLoad, object: self, userInfo: userInfo)
			
		}

	}
	
	func downloadSession(_ downloadSession: DownloadSession, shouldContinueAfterReceivingData data: Data, representedObject: AnyObject) -> Bool {
		return true
	}
	
	func downloadSession(_ downloadSession: DownloadSession, didReceiveUnexpectedResponse response: URLResponse, representedObject: AnyObject) {

	}
	
	func downloadSession(_ downloadSession: DownloadSession, didReceiveNotModifiedResponse: URLResponse, representedObject: AnyObject) {
		
	}
	
}
