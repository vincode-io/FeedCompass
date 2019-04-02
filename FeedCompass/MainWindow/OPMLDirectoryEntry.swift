//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation

struct OPMLDirectoryEntry: Codable, Hashable {
	
	var title: String?
	var url: String
	var description: String?
	var contributeURL: String?
	var userDefined: Bool?
	
	enum CodingKeys: String, CodingKey {
		case title
		case url
		case description
		case contributeURL
	}
	
}
