//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation
import RSParser
import RSWeb

public extension Notification.Name {
	static let OPMLDidDownload = Notification.Name(rawValue: "OPMLDidDownloadOPML")
}

final class OPMLDownloader {
	
	public struct UserInfoKey {
		public static let opmlDocument = "opmlDocument" // OPMLDidDownload
	}

	private struct OPMLLocation: Hashable {
		let title: String
		let url: String
	}

	private lazy var downloadSession: DownloadSession = {
		return DownloadSession(delegate: self)
	}()
	
	var progress: DownloadProgress {
		return downloadSession.progress
	}
	
	public func load() {
		
		let plist = Bundle.main.path(forResource: "OPML", ofType: "plist")!
		let opml = NSArray(contentsOfFile: plist)! as! [[String: Any]]
		
		let opmlLocations = opml.compactMap( { dict in
			return OPMLLocation(title: dict["title"] as! String, url: dict["url"] as! String)
		} )
		
		downloadSession.downloadObjects(Set(opmlLocations) as NSSet)
		
	}
	
}

// MARK: - DownloadSessionDelegate

extension OPMLDownloader: DownloadSessionDelegate {
	
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
			
			opmlDocument.title = opmlLocation.title
			
			var userInfo = [String: Any]()
			userInfo[OPMLDownloader.UserInfoKey.opmlDocument] = opmlDocument
			NotificationCenter.default.post(name: .OPMLDidDownload, object: self, userInfo: userInfo)
			
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
