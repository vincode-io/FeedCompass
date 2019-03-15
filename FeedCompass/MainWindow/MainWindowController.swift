//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore
import RSWeb

class MainWindowController: NSWindowController, NSUserInterfaceValidations {

	private var subscribeToOPMLWindowController: SubscribeToOPML?
	
	var splitViewController: NSSplitViewController {
		return contentViewController as! NSSplitViewController
	}
	
	var opmlViewController: OPMLViewController {
		return splitViewController.splitViewItems[0].viewController as! OPMLViewController
	}

	public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if item.action == #selector(subscribeToOPML(_:)) {
			return true
		}
		return false
		
	}
	
	@IBAction func subscribeToOPML(_ sender: Any?) {
		subscribeToOPMLWindowController = SubscribeToOPML()
		subscribeToOPMLWindowController!.runSheetOnWindow(window!)
	}
	
}
