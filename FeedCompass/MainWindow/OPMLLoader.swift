//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSParser
import RSWeb

public extension Notification.Name {
	static let OPMLDidLoad = Notification.Name(rawValue: "OPMLDidLoad")
	static let UserDidAddOPML = Notification.Name(rawValue: "UserDidAddOPML")
}

final class OPMLLoader {
	
	private static let opmlDirectoryURL = URL(string: "https://gist.githubusercontent.com/vincode-io/dec612f2da3270c94f2e0ca11f242753/raw/")!
	private lazy var downloadSession: DownloadSession = {
		return DownloadSession(delegate: self)
	}()

	static var shared = { OPMLLoader() }()
	
	struct UserInfoKey {
		public static let opmlDocument = "opmlDocument" // OPMLDidDownload
	}

	var directoryEntries = [String : OPMLDirectoryEntry]()
	
	var progress: DownloadProgress {
		return downloadSession.progress
	}
	
	func load() {

		download(OPMLLoader.opmlDirectoryURL) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
			
			guard let data = data else {
				let error = NSLocalizedString("Unable to load OPML Directory", comment: "Unable to load OPML Directory")
				NSApplication.shared.presentError(error)
				return
			}
			
			let decoder = JSONDecoder()
			guard var entries = try? decoder.decode([OPMLDirectoryEntry].self, from: data) else {
				let error = NSLocalizedString("Unable to decode OPML Directory", comment: "Unable to decode OPML Directory")
				NSApplication.shared.presentError(error)
				return
			}

			entries.forEach { self?.directoryEntries[$0.url] = $0 }
			
			if let userURLs = AppDefaults.userSubscriptions {
				for userURL in userURLs {
					entries.append(OPMLDirectoryEntry(title: nil, url: userURL, description: nil, contributeURL: nil, userDefined: nil))
				}
			}

			self?.downloadSession.downloadObjects(Set(entries) as NSSet)

		}
		
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
		
		guard let entry = representedObject as? OPMLDirectoryEntry else {
			return nil
		}
		
		guard let url = URL(string: entry.url) else {
			return nil
		}
		
		return URLRequest(url: url)
		
	}
	
	func downloadSession(_ downloadSession: DownloadSession, downloadDidCompleteForRepresentedObject representedObject: AnyObject, response: URLResponse?, data: Data, error: NSError?) {
		
		guard let entry = representedObject as? OPMLDirectoryEntry else {
			return
		}

		if let error = error {
			print("Error downloading \(entry.url) - \(error)")
			return
		}
		
		let parserData = ParserData(url: entry.url, data: data)
		if let opmlDocument = try? RSOPMLParser.parseOPML(with: parserData) {
			
			if entry.title != nil {
				opmlDocument.title = entry.title
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
