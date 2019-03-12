//Copyright © 2019 Vincode, Inc. All rights reserved.

import AppKit

extension NSStoryboard {
	
	func instantiateController<T>(ofType type: T.Type = T.self) -> T where T: NSViewController {
		
		let storyboardId = String(describing: type)
		guard let viewController = instantiateController(withIdentifier: storyboardId) as? T else {
			print("Unable to load view with Scene Identifier: \(storyboardId)")
			fatalError()
		}
		
		return viewController
		
	}
	
}
