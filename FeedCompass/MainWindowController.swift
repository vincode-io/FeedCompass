//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore
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
		
		if item.action == #selector(copyURL(_:)) {
			if opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.feedURL != nil {
				return true
			}
		}
		
		if item.action == #selector(openHomePage(_:)) {
			if opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.homePageURL != nil {
				return true
			}
		}
		
		return false
		
	}
	
	@IBAction func subscribe(_ sender: Any?) {
		guard let feedURL = opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.feedURL else {
			return
		}
		MacWebBrowser.openAsFeed(feedURL)
	}

	@IBAction func copyURL(_ sender: Any?) {
		guard let feedURL = opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.feedURL else {
			return
		}
		URLPasteboardWriter.write(urlString: feedURL, to: NSPasteboard.general)
	}
	
	@IBAction func openHomePage(_ sender: Any?) {
		guard let siteURL = opmlViewController.currentlySelectedOPMLItem?.feedSpecifier?.homePageURL, let url = URL(string: siteURL) else {
			return
		}
		MacWebBrowser.openURL(url, inBackground: false)
	}
	
}
