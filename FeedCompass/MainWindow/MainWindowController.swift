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

	@IBAction func openOPML(_ sender: Any?) {
		
		let panel = NSOpenPanel()
		panel.canDownloadUbiquitousContents = true
		panel.canResolveUbiquitousConflicts = true
		panel.canChooseFiles = true
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.resolvesAliases = true
		panel.allowedFileTypes = ["opml", "xml"]
		panel.allowsOtherFileTypes = false
		
		panel.beginSheetModal(for: window!) { result in
			if result == NSApplication.ModalResponse.OK, let url = panel.url {
				OPMLDownloader.shared.loadLocal(url: url)
			}
		}
		
	}
	
	@IBAction func subscribeToOPML(_ sender: Any?) {
		subscribeToOPMLWindowController = SubscribeToOPML()
		subscribeToOPMLWindowController!.runSheetOnWindow(window!)
	}
	
}
