//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

class OPMLOutlineView: NSOutlineView {

	override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
		var frame = super.frameOfCell(atColumn: column, row: row)
		frame.origin.x += 4.0
		frame.size.width -= 4.0
		return frame
	}
}
