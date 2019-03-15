//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore
import RSWeb

class MainWindowController: NSWindowController {

	private var subscribeToOPMLWindowController: SubscribeToOPML?
	
	var splitViewController: NSSplitViewController {
		return contentViewController as! NSSplitViewController
	}
	
	var opmlViewController: OPMLViewController {
		return splitViewController.splitViewItems[0].viewController as! OPMLViewController
	}

	@IBAction func subscribeToOPML(_ sender: Any?) {
		subscribeToOPMLWindowController = SubscribeToOPML()
		subscribeToOPMLWindowController!.runSheetOnWindow(window!)
	}
	
}
