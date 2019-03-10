//Copyright © 2019 Vincode, Inc. All rights reserved.

import Cocoa
import RSParser

class OPMLViewController: NSViewController {
	
	@IBOutlet weak var outlineView: NSOutlineView!
	
	private let opmlLocations: Set = [
		OPMLLocation(title: "feedBase.io - Hotlist", url: "http://opml.feedbase.io/hotlist.opml"),
		OPMLLocation(title: "iOS Development Blogs", url: "https://iosdevdirectory.com/opml/en/development.opml"),
		OPMLLocation(title: "iOS Design Blogs", url: "https://iosdevdirectory.com/opml/en/design.opml"),
		OPMLLocation(title: "iOS Marketing Blogs", url: "https://iosdevdirectory.com/opml/en/marketing.opml"),
		OPMLLocation(title: "iOS Development Company Blogs", url: "https://iosdevdirectory.com/opml/en/companies.opml"),
		OPMLLocation(title: "iOS Development Newsletters", url: "https://iosdevdirectory.com/opml/en/newsletters.opml"),
		OPMLLocation(title: "Chris Aldrich - Following", url: "https://www.boffosocko.com/wp-links-opml.php")
	]
	
	private let opmlDownloader = OPMLDownloader()
	private var opmls = [RSOPMLDocument]()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		outlineView.delegate = self
		outlineView.dataSource = self
		
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

extension OPMLViewController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		
		if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "OPMLTableVIewCell"), owner: nil) as? NSTableCellView {
			if let opmlDoc = item as? RSOPMLDocument {
				cell.textField?.stringValue = opmlDoc.title ?? "N/A"
			} else if let opmlItem = item as? RSOPMLItem {
				cell.textField?.stringValue = opmlItem.titleFromAttributes ?? "N/A"
			}
			return cell
		}
		
		return nil
		
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
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		
		guard outlineView == notification.object as? NSOutlineView else { return }
		let selectedRows = outlineView.selectedRowIndexes
		
		guard let opmlItem = selectedRows.map({ outlineView.item(atRow: $0) as! RSOPMLItem }).first else {
			return
		}
		
		guard let feedSpecifier = opmlItem.feedSpecifier else { return }
		
		let splitViewController = parent as! SplitViewController
		splitViewController.rssViewController.feedURL = feedSpecifier.feedURL
		
	}
	
}
