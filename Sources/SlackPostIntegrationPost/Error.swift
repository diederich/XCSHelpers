// Created by Stephan Diederich on 29.09.2018.
// Copyright © 2018 Stephan Diederich. All rights reserved.
//

import Foundation

public enum SlackPostError: Int, Error {
  case notRunningOnXcodeServer = 1
}

extension SlackPostError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .notRunningOnXcodeServer: return "Environment variables not found. Make sure to run this an Xcode server post build hook."
    }
  }
}
