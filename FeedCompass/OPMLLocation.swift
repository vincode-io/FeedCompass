//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation

public extension Notification.Name {
	static let OPMLDidDownload = Notification.Name(rawValue: "OPMLDidDownloadOPML")
}

public struct OPMLLocation: Hashable {
	
	public struct UserInfoKey {
		public static let opmlDocument = "opmlDocument" // OPMLDidDownload
	}
	
	let title: String
	let url: String
	
}
