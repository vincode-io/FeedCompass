//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore

class SubscribeToOPML: NSWindowController {

	@IBOutlet weak var urlTextField: NSTextField!
	@IBOutlet weak var subscribeButton: NSButton!
	
	private var hostWindow: NSWindow?

	convenience init() {
		self.init(windowNibName: NSNib.Name("SubscribeToOPML"))
	}

	func runSheetOnWindow(_ hostWindow: NSWindow) {

		self.hostWindow = hostWindow
		
		hostWindow.beginSheet(window!) { (returnCode: NSApplication.ModalResponse) -> Void in
			if returnCode == NSApplication.ModalResponse.OK {
				self.download()
			}
		}
		
	}

	private func download() {
		
		if var userURLs = AppDefaults.userSubscriptions {
			
			if userURLs.contains(urlTextField.stringValue) {
				let error = NSLocalizedString("Already subscribed to that URL", comment: "Already subscribed to that URL")
				window!.presentError(error)
				return
			}
			
			userURLs.insert(urlTextField.stringValue)
			AppDefaults.userSubscriptions = userURLs
			
		} else {
			
			AppDefaults.userSubscriptions = Set([urlTextField.stringValue])
			
		}
		
		OPMLLoader.shared.loadUserDefined(url: urlTextField.stringValue)
		
	}

	// MARK: NSTextFieldDelegate
	
	@objc func controlTextDidEndEditing(_ obj: Notification) {
		subscribeButton.isEnabled = urlTextField.stringValue.rs_stringMayBeURL()
	}
	
	@objc func controlTextDidChange(_ obj: Notification) {
		subscribeButton.isEnabled = urlTextField.stringValue.rs_stringMayBeURL()
	}

	// MARK: Actions
	
	@IBAction func cancel(_ sender: NSButton) {
		hostWindow!.endSheet(window!, returnCode: NSApplication.ModalResponse.cancel)
	}
	
	@IBAction func subscribe(_ sender: NSButton) {
		hostWindow!.endSheet(window!, returnCode: NSApplication.ModalResponse.OK)
	}
	
}
