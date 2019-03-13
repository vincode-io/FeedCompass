//Copyright © 2019 Vincode, Inc. All rights reserved.

import Cocoa

class PreferencesViewController: NSViewController {

	@IBOutlet weak var rssReaderPopUpButton: NSPopUpButton!
	@IBOutlet weak var urlTextField: NSTextField!
	@IBOutlet weak var urlContainerView: NSView!
	@IBOutlet weak var urlContainerTopConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		
        super.viewDidLoad()
		
		hideURL()
		
		if let preferredReader = AppDefaults.preferredReader {
			for menuItem in rssReaderPopUpButton.menu!.items {
				if menuItem.identifier?.rawValue == preferredReader {
					rssReaderPopUpButton.select(menuItem)
				}
			}
			if preferredReader == "other" {
				showURL()
				urlTextField.stringValue = AppDefaults.readerAddFeedURL ?? ""
			}
		}
		
    }
	
	override func viewWillDisappear() {
		updateDefaults()
	}
    
	@IBAction func rssReaderPopUpButtonSelected(_ sender: NSPopUpButton) {
		
		guard let selectedId = sender.selectedItem?.identifier?.rawValue else {
			return
		}
		
		if selectedId == "other" {
			showURL()
		} else {
			hideURL()
			urlTextField.stringValue = ""
		}
		
		AppDefaults.preferredReader = selectedId
		updateDefaults()

	}

	@IBAction func urlTextFieldUpdated(_ sender: NSTextField) {
		updateDefaults()
	}
	
}

private extension PreferencesViewController {
	
	func updateDefaults() {
		
		guard let selectedId = rssReaderPopUpButton.selectedItem?.identifier?.rawValue else {
			return
		}
		
		switch selectedId {
		case "feedbin":
			AppDefaults.readerAddFeedURL = "https://feedbin.com/?subscribe="
		case "feedly":
			AppDefaults.readerAddFeedURL = "https://feedly.com/i/subscription/feed/"
		case "newsblur":
			AppDefaults.readerAddFeedURL = "http://www.newsblur.com/?url="
		case "inoreader":
			AppDefaults.readerAddFeedURL = "https://www.inoreader.com/?add_feed="
		case "other":
			AppDefaults.readerAddFeedURL = urlTextField.stringValue
		default:
			AppDefaults.readerAddFeedURL = nil
		}
		
	}
	
	func showURL() {
		urlContainerView.isHidden = false
		urlContainerTopConstraint.constant = 8.0
	}
	
	func hideURL() {
		urlContainerView.isHidden = true
		urlContainerTopConstraint.constant = 0.0
	}
	
}
