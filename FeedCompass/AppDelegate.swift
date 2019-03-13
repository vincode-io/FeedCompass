//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	private var preferencesWindowController: NSWindowController?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	@IBAction func showPreferences(_ sender: Any?) {
		if preferencesWindowController == nil {
			let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
			preferencesWindowController = (storyboard.instantiateInitialController()! as! NSWindowController)
		}
		preferencesWindowController!.showWindow(self)
	}
	
}
