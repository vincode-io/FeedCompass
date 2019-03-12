//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSParser

class SplitViewController: NSSplitViewController {

	var opmlViewController: OPMLViewController {
		return self.splitViewItems[0].viewController as! OPMLViewController
	}
	
	var rssViewController: RSSFeedViewController {
		return self.splitViewItems[1].viewController as! RSSFeedViewController
	}

	func showRSSFeed(_ parsedFeed: ParsedFeed) {
		
		let feedController = storyboard!.instantiateController(ofType: RSSFeedViewController.self)
		feedController.parsedFeed = parsedFeed
		
		let feedSplitViewItem = NSSplitViewItem(viewController: feedController)
		splitViewItems[1] = feedSplitViewItem
		
		view.window?.recalculateKeyViewLoop()
		
	}

	func showRSSMessage(_ message: String) {
		
		let messageController = storyboard!.instantiateController(ofType: RSSMessageViewController.self)
		messageController.message = message
		
		let messageSplitViewItem = NSSplitViewItem(viewController: messageController)
		splitViewItems[1] = messageSplitViewItem
		
		view.window?.recalculateKeyViewLoop()
		
	}

}
