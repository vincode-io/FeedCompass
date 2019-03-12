//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

class RSSMessageViewController: NSViewController {
	
	@IBOutlet weak var messageLabel: NSTextField!
	var message: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		messageLabel.stringValue = message ?? ""
	}
	
}
 	
