//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore
import RSParser
import RSWeb

class OPMLViewController: NSViewController {
	
	@IBOutlet weak var outlineView: NSOutlineView!
	
	var splitViewController: SplitViewController {
		return self.parent as! SplitViewController
	}
	
	private let opmlLocations: Set = [
		OPMLLocation(title: "feedBase - Hotlist", url: "http://opml.feedbase.io/hotlist.opml"),
		OPMLLocation(title: "iOS Developers", url: "https://iosdevdirectory.com/opml/en/development.opml"),
		OPMLLocation(title: "iOS Design", url: "https://iosdevdirectory.com/opml/en/design.opml"),
		OPMLLocation(title: "iOS Marketing", url: "https://iosdevdirectory.com/opml/en/marketing.opml"),
		OPMLLocation(title: "iOS Development Companies", url: "https://iosdevdirectory.com/opml/en/companies.opml"),
		OPMLLocation(title: "iOS Development Newsletters", url: "https://iosdevdirectory.com/opml/en/newsletters.opml"),
		OPMLLocation(title: "Chris Aldrich - Following", url: "https://www.boffosocko.com/wp-links-opml.php")
	]
	
	private let opmlDownloader = OPMLDownloader()
	private var opmls = [RSOPMLDocument]()
	
	private let folderImage: NSImage? = {
		return NSImage(named: "NSFolder")
	}()
	
	private let faviconImage: NSImage? = {
		let path = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns"
		return NSImage(contentsOfFile: path)
	}()
	
	var currentlySelectedOPMLItem: RSOPMLItem? {
		let selectedRows = outlineView.selectedRowIndexes
		return selectedRows.map({ outlineView.item(atRow: $0) as! RSOPMLItem }).first
	}

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		outlineView.delegate = self
		outlineView.dataSource = self
		outlineView.setDraggingSourceOperationMask(.copy, forLocal: false)
		
		NotificationCenter.default.addObserver(self, selector: #selector(opmlDidDownload(_:)), name: .OPMLDidDownload, object: nil)

		opmlDownloader.load(opmlLocations)
		
	}
	
	// MARK: - Notifications
	
	@objc func opmlDidDownload(_ note: Notification) {
		
		guard let opmlDocument = note.userInfo?[OPMLLocation.UserInfoKey.opmlDocument] as? RSOPMLDocument else {
			return
		}
		
		opmls.append(opmlDocument)
		opmls.sort(by: { return $0.title.caseInsensitiveCompare($1.title) == .orderedAscending })
		outlineView.reloadData()
	}

}

// MARK: NSOutlineViewDataSource

extension OPMLViewController: NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		
		if item == nil {
			return opmls[index]
		}
		
		let opml = item as! RSOPMLItem
		return opml.children![index]
		
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		
		if item == nil {
			return opmls.count
		}
		
		let opml = item as! RSOPMLItem
		return opml.children?.count ?? 0
		
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		let opml = item as! RSOPMLItem
		return opml.children?.count ?? 0 > 0
	}
	
}

// MARK: NSOutlineViewDelegate

extension OPMLViewController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		
		if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "OPMLTableViewCell"), owner: nil) as? NSTableCellView {
			if let opmlDoc = item as? RSOPMLDocument {
				cell.imageView?.image = folderImage
				cell.textField?.stringValue = opmlDoc.title ?? "N/A"
			} else if let opmlItem = item as? RSOPMLItem {
				if opmlItem.children?.count ?? 0 > 0 {
					cell.imageView?.image = folderImage
				} else {
					cell.imageView?.image = faviconImage
				}
 				cell.textField?.stringValue = opmlItem.titleFromAttributes ?? "N/A"
			}
			return cell
		}
		
		return nil
		
	}
	
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		return 22.0
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
		let opml = item as! RSOPMLItem
		return opml.children?.count ?? 0 > 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		let opml = item as! RSOPMLItem
		return opml.children?.count ?? 0 < 1
	}

	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
	}
	
	func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
		
		guard items.count > 0 else {
			return false
		}
		
		let opml = items[0] as! RSOPMLItem
		
		guard let feedURL = opml.feedSpecifier?.feedURL else {
			return false
		}
		
		URLPasteboardWriter.write(urlString: feedURL, to: pasteboard)
		return true
		
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		
		guard let opmlItem = currentlySelectedOPMLItem else {
			let noneSelected = NSLocalizedString("None Selected", comment: "No RSS Feed was selected")
			splitViewController.showRSSMessage(noneSelected)
			return
		}
		
		guard let urlString = opmlItem.feedSpecifier?.feedURL, let url = URL(string: urlString) else {
			let invalidURL = NSLocalizedString("Invalid Feed URL", comment: "RRS Feed URL was invalid")
			splitViewController.showRSSMessage(invalidURL)
			return
		}
		
		let loading = NSLocalizedString("Loading...", comment: "RRS Feed is currently loading.")
		splitViewController.showRSSMessage(loading)

		download(url, downloadCallback)
	}
	
}

// MARK: NSMenuDelegate

extension OPMLViewController: NSMenuDelegate {

	public func menuNeedsUpdate(_ menu: NSMenu) {
		menu.removeAllItems()
		guard let contextualMenu = contextualMenuForClickedRow() else {
			return
		}
		menu.takeItems(from: contextualMenu)
	}

}

// MARK: Contextual Menu Actions

extension OPMLViewController {

	@objc func subscribeFromContextualMenu(_ sender: Any?) {
		guard let menuItem = sender as? NSMenuItem, let urlString = menuItem.representedObject as? String else {
			return
		}
		MacWebBrowser.openAsFeed(urlString)
	}
	
	@objc func copyURLFromContextualMenu(_ sender: Any?) {
		guard let menuItem = sender as? NSMenuItem, let urlString = menuItem.representedObject as? String else {
			return
		}
		URLPasteboardWriter.write(urlString: urlString, to: NSPasteboard.general)
	}
	
	@objc func openURLFromContextualMenu(_ sender: Any?) {
		guard let menuItem = sender as? NSMenuItem,
			let urlString = menuItem.representedObject as? String,
			let url = URL(string: urlString)
		else {
			return
		}
		MacWebBrowser.openURL(url, inBackground: false)
	}
	
}


// MARK: Private Functions

private extension OPMLViewController {
	
	func downloadCallback(data: Data?, response: URLResponse?, error: Error?) {
		
		guard let url = response?.url?.absoluteString, let data = data else {
			let feedNotFound = NSLocalizedString("Feed Not Found", comment: "RRS Feed was not found")
			splitViewController.showRSSMessage(feedNotFound)
			return
		}
		
		let parserData = ParserData(url: url, data: data)
		if let parsedFeed = RSSParser.parse(parserData) {
			if parsedFeed.items.count > 0 {
				splitViewController.showRSSFeed(parsedFeed)
			} else {
				let emptyFeed = NSLocalizedString("Empty Feed", comment: "RRS Feed had no articles")
				splitViewController.showRSSMessage(emptyFeed)
			}
		}
		
	}

	func contextualMenuForClickedRow() -> NSMenu? {
		
		let row = outlineView.clickedRow
		guard row != -1, let opmlItem = outlineView.item(atRow: row) as? RSOPMLItem else {
			return nil
		}
		
		if let opmlFeedSpecifier = opmlItem.feedSpecifier {
			return menuForFeed(opmlFeedSpecifier)
		}
		
		return nil
		
	}

	func menuForFeed(_ opmlFeedSpecifier: RSOPMLFeedSpecifier) -> NSMenu? {
		
		let menu = NSMenu(title: "")
		
		let subscribeItem = menuItem(NSLocalizedString("Subscribe", comment: "Command"), #selector(subscribeFromContextualMenu(_:)), opmlFeedSpecifier.feedURL)
		menu.addItem(subscribeItem)
		
		menu.addItem(NSMenuItem.separator())
		
		let copyItem = menuItem(NSLocalizedString("Copy Feed URL to Clipboard", comment: "Command"), #selector(copyURLFromContextualMenu(_:)), opmlFeedSpecifier.feedURL)
		menu.addItem(copyItem)

		if let homePageURL = opmlFeedSpecifier.homePageURL {
			let item = menuItem(NSLocalizedString("Open Feed Home Page", comment: "Command"), #selector(openURLFromContextualMenu(_:)), homePageURL)
			menu.addItem(item)
		}
		
		return menu
	}
	

	func menuItem(_ title: String, _ action: Selector, _ representedObject: Any) -> NSMenuItem {
		let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
		item.representedObject = representedObject
		item.target = self
		return item
	}

}
