//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation
import RSParser
import RSWeb

final class OPMLDownloader {
	
	private lazy var downloadSession: DownloadSession = {
		return DownloadSession(delegate: self)
	}()
	
	var progress: DownloadProgress {
		return downloadSession.progress
	}
	
	public func load(_ opmlLocations: Set<OPMLLocation>) {
		downloadSession.downloadObjects(opmlLocations as NSSet)
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
			userInfo[OPMLLocation.UserInfoKey.opmlDocument] = opmlDocument
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
