//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation
import RSWeb

extension MacWebBrowser {

	@discardableResult public class func openAsFeed(_ url: String) -> Bool {
		
		if let subscribeURL = AppDefaults.readerAddFeedURL {
			guard let fullURL = URL(string: subscribeURL + url) else {
				return false
			}
			return MacWebBrowser.openURL(fullURL, inBackground: false)
		} else {
			return openLocalReader(url)
		}
		
	}

	private class func openLocalReader(_ url: String) -> Bool {
		
		guard let index = url.firstIndex(of: ":") else {
			return false
		}
		
		let newFeedURL = "feed\(url.suffix(from: index))"
		
		guard let url = URL(string: newFeedURL) else {
			return false
		}
		
		return MacWebBrowser.openURL(url, inBackground: false)
		
	}
	
}
