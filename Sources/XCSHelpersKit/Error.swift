// Created by Stephan Diederich on 29.09.2018.
// Copyright © 2018 Stephan Diederich. All rights reserved.
//

import Foundation

public enum XCSHelpersError: Error {
  case unsupportedMacOSVersion
  case notRunningOnXcodeServer
  case failedToCommunicateWithSlack(error: String?)

  case unknownError
}

extension XCSHelpersError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .unsupportedMacOSVersion: return "Unsupported MacOSVersion. Requires 10.13 or higher"
    case .notRunningOnXcodeServer: return "Environment variables not found. Make sure to run this an Xcode server post build hook."
    case .failedToCommunicateWithSlack(let error): return "Failed to talk to Slack. Error: \(error ?? "Unknown error")"
    case .unknownError: return "Unknown error. Should not happen"
    }
  }

  public var code: Int32 {
    switch self {
    case .unsupportedMacOSVersion: return 1
    case .notRunningOnXcodeServer: return 2
    case .failedToCommunicateWithSlack: return 3
    case .unknownError: return 21
    }
  }
}
