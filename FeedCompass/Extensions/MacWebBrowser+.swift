//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation
import RSWeb

extension MacWebBrowser {

	@discardableResult public class func openAsFeed(_ url: String) -> Bool {
		
		if let subscribeURL = AppDefaults.readerAddFeedURL {
			guard subscribeURL.lowercased().starts(with: "http") else {
				return false
			}
			guard let fullURL = URL(string: subscribeURL + url) else {
				return false
			}
			return MacWebBrowser.openURL(fullURL, inBackground: false)
		} else {
			return openLocalReader(url)
		}
		
	}

	private class func openLocalReader(_ urlString: String) -> Bool {
		
		guard let url = URL(string: "feed:\(urlString)") else {
			return false
		}
		
		return MacWebBrowser.openURL(url, inBackground: false)
		
	}
	
}
