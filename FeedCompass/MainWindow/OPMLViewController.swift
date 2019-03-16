//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit
import RSCore
import RSParser
import RSWeb

class OPMLViewController: NSViewController, NSUserInterfaceValidations {
	
	@IBOutlet weak var outlineView: NSOutlineView!
	
	var splitViewController: SplitViewController {
		return self.parent as! SplitViewController
	}
	
	private var opmls = [RSOPMLDocument]()
	
	private let folderImage: NSImage? = {
		return NSImage(named: "NSFolder")
	}()
	
	private let faviconImage: NSImage? = {
		let path = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns"
		return NSImage(contentsOfFile: path)
	}()
	
	var currentlySelectedOPMLItem: RSOPMLItem? {
		let selectedItems = currentlySelectedOPMLItems
		if selectedItems.count == 1 {
			return selectedItems[0]
		}
		return nil
	}
	
	var currentlySelectedOPMLItems: [RSOPMLItem] {
		let selectedRows = outlineView.selectedRowIndexes
		return selectedRows.map({ outlineView.item(atRow: $0) as! RSOPMLItem })
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		outlineView.delegate = self
		outlineView.dataSource = self
		outlineView.setDraggingSourceOperationMask(.copy, forLocal: false)
		
		NotificationCenter.default.addObserver(self, selector: #selector(opmlDidDownload(_:)), name: .OPMLDidLoad, object: nil)

		OPMLLoader.shared.load()
		
	}
	
	public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		
		if item.action == #selector(delete(_:)) {
			for currentItem in currentlySelectedOPMLItems {
				if let currentDoc = currentItem as? RSOPMLDocument {
					if !(AppDefaults.userSubscriptions?.contains(currentDoc.url) ?? false) {
						return false
					}
				} else {
					return false
				}
			}
			return true
		}
		
		if item.action == #selector(subscribe(_:)) {
			if currentlySelectedOPMLItem?.feedSpecifier?.feedURL != nil {
				return true
			}
		}
		
		if item.action == #selector(copyURL(_:)) {
			if currentlySelectedOPMLItem?.feedSpecifier?.feedURL != nil {
				return true
			}
		}
		
		if item.action == #selector(openHomePage(_:)) {
			if currentlySelectedOPMLItem?.feedSpecifier?.homePageURL != nil {
				return true
			}
		}
		
		if item.action == #selector(subscribeFromContextualMenu(_:)) {
			return true
		}
		
		if item.action == #selector(copyURLFromContextualMenu(_:)) {
			return true
		}
		
		if item.action == #selector(openURLFromContextualMenu(_:)) {
			return true
		}
		
		return false
		
	}

	
	// MARK: - Notifications
	
	@objc func opmlDidDownload(_ note: Notification) {
		
		guard let opmlDocument = note.userInfo?[OPMLLoader.UserInfoKey.opmlDocument] as? RSOPMLDocument else {
			return
		}
		
		opmls.append(opmlDocument)
		opmls.sort(by: { return $0.title.caseInsensitiveCompare($1.title) == .orderedAscending })
		outlineView.reloadData()
	}
	
	// MARK: Actions
	
	@IBAction func delete(_ sender: AnyObject?) {

		for currentItem in currentlySelectedOPMLItems {
			
			if let currentDoc = currentItem as? RSOPMLDocument {
				
				let indexSet = IndexSet(integer: outlineView.childIndex(forItem: currentDoc))
				outlineView.removeItems(at: indexSet, inParent: nil, withAnimation: .effectFade)
				
				var subs = AppDefaults.userSubscriptions
				subs?.remove(currentDoc.url)
				AppDefaults.userSubscriptions = subs
				
			}
			
		}
		
	}
	
	@IBAction func subscribe(_ sender: Any?) {
		guard let feedURL = currentlySelectedOPMLItem?.feedSpecifier?.feedURL else {
			return
		}
		MacWebBrowser.openAsFeed(feedURL)
	}
	
	@IBAction func copyURL(_ sender: Any?) {
		guard let feedURL = currentlySelectedOPMLItem?.feedSpecifier?.feedURL else {
			return
		}
		URLPasteboardWriter.write(urlString: feedURL, to: NSPasteboard.general)
	}
	
	@IBAction func openHomePage(_ sender: Any?) {
		guard let siteURL = currentlySelectedOPMLItem?.feedSpecifier?.homePageURL, let url = URL(string: siteURL) else {
			return
		}
		MacWebBrowser.openURL(url, inBackground: false)
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
				cell.textField?.stringValue = titleOrUntitled(opmlDoc.title)
			} else if let opmlItem = item as? RSOPMLItem {
				if opmlItem.children?.count ?? 0 > 0 {
					cell.imageView?.image = folderImage
				} else {
					cell.imageView?.image = faviconImage
				}
 				cell.textField?.stringValue = titleOrUntitled(opmlItem.titleFromAttributes)
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
		return true
	}

	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		guard let opmlItem = item as? RSOPMLItem, let feedURL = opmlItem.feedSpecifier?.feedURL else {
			return nil
		}
		return URLPasteboardWriter(urlString: feedURL)
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		
		let opmlItems = currentlySelectedOPMLItems
		
		// Is nothing selected?
		if opmlItems.count < 1 {
			let noneSelected = NSLocalizedString("None Selected", comment: "No RSS Feed was selected")
			splitViewController.showRSSMessage(noneSelected)
			return
		}
		
		// Did they select multiple items?
		if opmlItems.count > 1 {
			let noneSelected = NSLocalizedString("Multiple Selected", comment: "Multiple RSS Feeds selected")
			splitViewController.showRSSMessage(noneSelected)
			return
		}
		
		// Did they select a single folder?
		if opmlItems.count == 1 && opmlItems[0].children?.count ?? 0 > 0 {
			splitViewController.showRSSMessage("")
			return
		}
		
		// Is the opml file dorked?
		guard let urlString = opmlItems[0].feedSpecifier?.feedURL, let url = URL(string: urlString) else {
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
	
	func titleOrUntitled(_ title: String?) -> String {
		if title == nil || title?.count ?? 0 < 1 {
			return NSLocalizedString("(Untitled)", comment: "Untitled entity")
		}
		return title!
	}

}
