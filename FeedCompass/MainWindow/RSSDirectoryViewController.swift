//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSWeb

class RSSDirectoryViewController: NSViewController {
	
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var descriptionLabel: NSTextField!
	@IBOutlet weak var contributePitchLabel: NSTextField!
	@IBOutlet weak var contributeButton: NSButton!
	
	var entry: OPMLDirectoryEntry?

	override func viewDidLoad() {

		super.viewDidLoad()

		titleLabel.stringValue = entry?.title ?? ""
		descriptionLabel.stringValue = entry?.description ?? ""

		if entry?.contributeURL == nil {
			contributeButton.isHidden = true
			contributePitchLabel.isHidden = true
		}
		
	}
	
	@IBAction func contribute(_ sender: Any) {
		if let urlString = entry?.contributeURL, let url = URL(string: urlString) {
			MacWebBrowser.openURL(url, inBackground: false)
		}
	}
	
	@IBAction func learnMore(_ sender: Any) {
		let url = URL(string: "https://vincode.io/contribute-to-feed-compass/")!
		MacWebBrowser.openURL(url, inBackground: false)
	}
	
}
