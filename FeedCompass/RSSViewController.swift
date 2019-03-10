//Copyright © 2019 Vincode, Inc. All rights reserved.

import Cocoa
import RSCore
import RSParser
import RSWeb

class RSSViewController: NSViewController {

	@IBOutlet weak var tableView: NSTableView!
	
	var feedURL: String? {
		didSet {
			refresh()
		}
	}
	
	var parsedFeed: ParsedFeed?
	var parsedItems = [ParsedItem]()
	
	override func viewDidLoad() {
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	private func refresh() {

		guard let urlString = feedURL, let url = URL(string: urlString) else {
			return
		}
		
		download(url, downloadCallback)
	}
	
	private func downloadCallback(data: Data?, response: URLResponse?, error: Error?) {
		
		guard let url = response?.url?.absoluteString else { return }
		guard let data = data else { return }
		
		let parserData = ParserData(url: url, data: data)
		if let parsedFeed = RSSParser.parse(parserData) {
		
			self.parsedFeed = parsedFeed
			parsedItems = Array(parsedFeed.items)
		
			parsedItems.sort(by: { leftItem, rightItem in
				if let leftDate = leftItem.datePublished, let rightDate = rightItem.datePublished {
					return leftDate.compare(rightDate) == .orderedDescending
				}
				return false
			})
		
			tableView.reloadData()
			tableView.scrollTo(row: 0)
		}
	}
	
}

extension RSSViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return parsedItems.count
	}
	
}

extension RSSViewController: NSTableViewDelegate {
	
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	private static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		return formatter
	}()
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RSSTableViewCell"), owner: nil) as? RSSTableCellView {
			
			if let title = parsedItems[row].title {
				var s = title.replacingOccurrences(of: "\n", with: "")
				s = s.replacingOccurrences(of: "\r", with: "")
				s = s.replacingOccurrences(of: "\t", with: "")
				s = s.rsparser_stringByDecodingHTMLEntities()
				s = s.replacingOccurrences(of: "↦", with: "")
				s = s.rs_stringByTrimmingWhitespace()
				s = s.rs_stringWithCollapsedWhitespace()
				cell.titleTextField.stringValue = s
			} else {
				cell.titleTextField.stringValue = "------------"
			}

			if let publishedDate = parsedItems[row].datePublished {
				cell.publishedTextField.stringValue = RSSViewController.dateString(publishedDate)
			} else {
				cell.publishedTextField.stringValue = ""
			}
			
			if let summary = parsedItems[row].contentHTML {
				var s = summary.rsparser_stringByDecodingHTMLEntities()
				s = s.rs_string(byStrippingHTML: 300)
				s = s.rs_stringByTrimmingWhitespace()
				s = s.rs_stringWithCollapsedWhitespace()
				cell.summaryTextField.stringValue = s
			} else {
				cell.summaryTextField.stringValue = ""
			}
			
			return cell
		}
		
		return nil
	}

	static func dateString(_ date: Date) -> String {
		if NSCalendar.rs_dateIsToday(date) {
			return timeFormatter.string(from: date)
		}
		return dateFormatter.string(from: date)
	}
	
}
