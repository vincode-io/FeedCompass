//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

class RSSDirectoryViewController: NSViewController {
	
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var descriptionLabel: NSTextField!
	@IBOutlet weak var contributePitchLabel: NSTextField!
	@IBOutlet weak var contributeLabel: NSTextField!
	@IBOutlet weak var contributeURLLabel: NSTextField!
	
	var entry: OPMLDirectoryEntry?

	override func viewDidLoad() {

		super.viewDidLoad()

		titleLabel.stringValue = entry?.title ?? ""
		descriptionLabel.stringValue = entry?.description ?? ""

		if let contributeURL = entry?.contributeURL {
			
			let attrString = NSMutableAttributedString(string: contributeURL)
			let range = NSRange(location: 0, length: attrString.length)
		
			attrString.beginEditing()
			attrString.addAttribute(.link, value: contributeURL, range: range)
			attrString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
			attrString.endEditing()
		
			contributeURLLabel.allowsEditingTextAttributes = true
			contributeURLLabel.isSelectable = true
			contributeURLLabel.attributedStringValue = attrString
			
		} else {
			
			contributePitchLabel.isHidden = true
			contributeLabel.isHidden = true
			contributeURLLabel.isHidden = true
			
		}
		
	}
	
}
