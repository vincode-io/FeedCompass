//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation

struct AppDefaults {
	
	struct Key {
		static let preferredReader = "preferredReader"
		static let readerAddFeedURL = "readerAddFeedURL"
		static let userSubscriptions = "userSubscriptions"
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
	
	static var userSubscriptions: Set<String>? {
		get {
			if let subs = UserDefaults.standard.array(forKey: Key.userSubscriptions) {
				return Set(subs.compactMap { $0 as? String })
			}
			return nil
		}
		set {
			if newValue != nil {
				UserDefaults.standard.set(Array(newValue!), forKey: Key.userSubscriptions)
			} else {
				UserDefaults.standard.set(newValue, forKey: Key.userSubscriptions)
			}
		}
	}
	
}
