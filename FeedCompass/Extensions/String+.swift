//Copyright © 2019 Vincode, Inc. All rights reserved.

import Foundation

// This allows Strings to be directly thrown as errors.  It is a quick and easy way to do
// what is essentially an untyped error with a message.
extension String: LocalizedError {
	public var errorDescription: String? {
		return self
	}
}
