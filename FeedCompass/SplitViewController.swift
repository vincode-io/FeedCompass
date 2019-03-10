//Copyright © 2019 Vincode, Inc. All rights reserved.

import Cocoa

class SplitViewController: NSSplitViewController {

	var opmlViewController: OPMLViewController {
		return self.splitViewItems[0].viewController as! OPMLViewController
	}
	
	var rssViewController: RSSViewController {
		return self.splitViewItems[1].viewController as! RSSViewController
	}
	
}
