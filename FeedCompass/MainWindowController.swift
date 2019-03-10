//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSWeb

class MainWindowController: NSWindowController, NSUserInterfaceValidations {

	var splitViewController: NSSplitViewController {
		return contentViewController as! NSSplitViewController
	}
	
	var opmlViewController: OPMLViewController {
		return splitViewController.splitViewItems[0].viewController as! OPMLViewController
	}

	public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		
		if item.action == #selector(subscribe(_:)) {
			if opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.feedURL != nil {
				return true
			}
		}
		
		return false
	}
	
	@IBAction func subscribe(_ sender: Any?) {
		
		guard let feedURL = opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.feedURL else {
			return
		}
		
		guard let index = feedURL.firstIndex(of: ":") else {
			return
		}
		
		let newFeedURL = "feed\(feedURL.suffix(from: index))"
		
		guard let url = URL(string: newFeedURL) else {
			return
		}
		
		MacWebBrowser.openURL(url, inBackground: false)
	}

}
