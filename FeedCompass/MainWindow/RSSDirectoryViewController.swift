//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

class RSSDirectoryViewController: NSViewController {
	
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var descriptionLabel: NSTextField!
	@IBOutlet weak var contactLabel: NSTextField!
	
	var entry: OPMLDirectoryEntry?

	override func viewDidLoad() {

		super.viewDidLoad()

		titleLabel.stringValue = entry?.title ?? ""
		descriptionLabel.stringValue = entry?.description ?? ""

		let contactURL = entry?.contactURL ?? ""
		let attrString = NSMutableAttributedString(string: contactURL)
		let range = NSRange(location: 0, length: attrString.length)
		
		attrString.beginEditing()
		attrString.addAttribute(.link, value: contactURL, range: range)
		attrString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
		attrString.endEditing()
		
		contactLabel.allowsEditingTextAttributes = true
		contactLabel.isSelectable = true
		contactLabel.attributedStringValue = attrString
		
	}
	
}
