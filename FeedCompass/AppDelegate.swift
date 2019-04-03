//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSWeb

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

	func application(_ sender: NSApplication, openFile filename: String) -> Bool {
		if let url = URL(string: "file://\(filename)") {
			OPMLLoader.shared.loadLocal(url: url)
			return true
		}
		return false
	}
	
	func application(_ sender: NSApplication, openFiles filenames: [String]) {
		filenames.forEach { filename in
			if let url = URL(string: "file://\(filename)") {
				OPMLLoader.shared.loadLocal(url: url)
			}
		}
	}
	
	@IBAction func showPreferences(_ sender: Any?) {
		if preferencesWindowController == nil {
			let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
			preferencesWindowController = (storyboard.instantiateInitialController()! as! NSWindowController)
		}
		preferencesWindowController!.showWindow(self)
	}
	
	@IBAction func showHelp(_ sender: Any?) {
		MacWebBrowser.openURL(URL(string: "https://vincode.io/feed-compass-help/")!, inBackground: false)
	}
	
	@IBAction func showWebsite(_ sender: Any?) {
		MacWebBrowser.openURL(URL(string: "https://vincode.io/feed-compass/")!, inBackground: false)
	}
	
	@IBAction func showGithubRepo(_ sender: Any?) {
		MacWebBrowser.openURL(URL(string: "https://github.com/vincode-io/FeedCompass")!, inBackground: false)
	}
	
	@IBAction func showGithubIssues(_ sender: Any?) {
		MacWebBrowser.openURL(URL(string: "https://github.com/vincode-io/FeedCompass/issues")!, inBackground: false)
	}

}
