//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation

struct AppDefaults {
	
	struct Key {
		static let preferredReader = "preferredReader"
		static let readerAddFeedURL = "readerAddFeedURL"
	}

	static var preferredReader: String? {
		get {
			return UserDefaults.standard.string(forKey: Key.preferredReader)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Key.preferredReader)
		}
	}
	
	static var readerAddFeedURL: String? {
		get {
			return UserDefaults.standard.string(forKey: Key.readerAddFeedURL)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Key.readerAddFeedURL)
		}
	}
	
}
