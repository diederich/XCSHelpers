// Created by Stephan Diederich on 29.09.2018.
// Copyright © 2018 Stephan Diederich. All rights reserved.
//

import Foundation

public struct SlackPost: Encodable {
  // multiple posts from the same user name get collapsed
  public var username: String?
  public var attachments: [SlackAttachment]
}

public struct SlackAttachment: Encodable {
  public var title: String
  public var title_link: String?
  public var text: String
  public var fallBack: String?
  public var author_name: String?
  public var color: String?
  //  "fields": [
  //  ]
}

// MARK: - Create slack post from Xcode Servers environment variables
extension SlackPost {
  /// Initializes a Slack post from the Xcode Server environment variables present in a post integration
  ///
  /// - Parameters:
  ///   - env: Environmenet
  ///   - serverHostname: hostname of the server. If present, links can be added (like xcbot://hostname/...)
  /// - Throws: XcodeServerHelpersError
  public init(xcodeServerEnvironment env: XcodeServerEnvironment,
              serverHostname: String? = nil) throws {
    guard env[.XCS] == "1" else {
      throw XcodeServerHelpersError.notRunningOnXcodeServer
    }
    //TODO should the username be the 'server' and the author the bot?
    let botname = env[.XCS_BOT_NAME] ?? "<Unknown Bot>"
    username = botname

    let branchName = env[.XCS_PRIMARY_REPO_BRANCH]
    let revision = env[.XCS_PRIMARY_REPO_REVISION]
    let tagName = env[.XCS_PRIMARY_REPO_TAG]
    let scmString = tagName ?? revision ?? branchName ?? "<unknown-revision>"
    let result = env[.XCS_INTEGRATION_RESULT] ?? "<no-result>"

    let title = "\(botname) finished integration #\(env[.XCS_INTEGRATION_NUMBER] ?? "-") on `\(scmString)` with status: `\(env[.XCS_INTEGRATION_RESULT] ?? "-")`"

    let titleLink: String? = {
      if let hostname = serverHostname, let botID = env[.XCS_BOT_ID], let integrationID = env[.XCS_INTEGRATION_ID] {
        return "xcbot://\(hostname)/botID/\(botID)/integrationID/\(integrationID)"
      } else {
        return nil
      }
    }()
    var text = ""
    if let testCount = Int(env[.XCS_TESTS_COUNT] ?? ""), let testsChange = Int(env[.XCS_TESTS_CHANGE] ?? ""), let testFailureCount = Int(env[.XCS_TEST_FAILURE_COUNT] ?? ""), let testFailureChange = Int(env[.XCS_TEST_FAILURE_CHANGE] ?? "") {
      var texts = [String]()
      if testsChange != 0 {
        texts.append("\(testCount) tests (Δ\(testsChange))")
      }
      if testFailureCount > 0 || testFailureChange != 0 {
        texts.append("\(testFailureCount) failed (Δ\(testFailureChange))\n")
      }
      if !texts.isEmpty {
        text += texts.joined(separator: " - ")
        text += "\n"
      }
    }
    if let analyzerWarningCount = Int(env[.XCS_ANALYZER_WARNING_COUNT] ?? ""), let analyzerWarningChange = Int(env[.XCS_ANALYZER_WARNING_CHANGE] ?? ""),
      let warningCount = Int(env[.XCS_WARNING_COUNT] ?? ""), let warningChange = Int(env[.XCS_WARNING_CHANGE] ?? ""),
      let errorCount = Int(env[.XCS_ERROR_COUNT] ?? ""), let errorChange = Int(env[.XCS_ERROR_CHANGE] ?? "") {

      var warningsText = [String]()
      if analyzerWarningChange != 0 || analyzerWarningCount > 0 {
        warningsText.append("\(analyzerWarningCount) Analyzer Warnings (Δ\(analyzerWarningChange)) ")
      }
      if  warningChange != 0 || warningCount > 0 {
        warningsText.append("\(warningCount) Warnings (Δ\(warningChange))")
      }
      if errorChange != 0 || errorCount > 0 {
        warningsText.append("\(errorCount) Errors (Δ\(errorChange))")
      }

      if !warningsText.isEmpty {
        text += warningsText.joined(separator: ",")
        text += "\n"
      }
    }
    let fallbackMessage = """
      Run \(env[.XCS_INTEGRATION_NUMBER] ?? "-") on `\(branchName)` finished with status: \(result).
      \(text)
      """

    let colorString = IntegrationResult(rawValue: env[.XCS_INTEGRATION_RESULT] ?? "")?.colorString
    attachments = [SlackAttachment(title: title,
                                   title_link: titleLink,
                                   text: text,
                                   fallBack: fallbackMessage,
                                   author_name: nil,
                                   color: colorString)
    ]
  }

  enum IntegrationResult: String, Codable, Equatable {
    case succeeded, warnings, canceled, unknown
    case testFailures = "test-failures"
    case buildErrors = "build-errors"
    case analyzerWarnings = "analyzer-warnings"
    case buildFailed = "build-failed"
    case checkoutError = "checkout-error"
    case internalError  = "internal-error"
    case internalCheckoutError = "internal-checkout-error"
    case internalBuildError = "internal-build-error"
    case internalProcessingError = "internal-processing-error"
    case triggerError = "trigger-error"

    var colorString: String {
      switch self {
      case .canceled, .unknown:
        return "#8E8E91"
      case .succeeded:
        return "#009637"
      case .analyzerWarnings:
        return "#394FF1"
      case .warnings:
        return "#FEC400"
      case .buildErrors, .buildFailed, .internalError, .internalBuildError, .internalCheckoutError,
           .internalProcessingError, .checkoutError, .triggerError, .testFailures:
        return "#E11415"
      }
    }
  }
}


/// API Request for posting to slack. For consumption by @class NetworkService
public struct PostToSlack: APIRequest {
  public typealias Response = String
  public var url: URL { return slackHookURL }
  public var method: HTTPMethod { return  .post }
  public var body: Data {
    return try! JSONEncoder().encode(post)
  }

  var post: SlackPost
  var slackHookURL: URL
  public init(post: SlackPost, slackHookURL: URL) {
    self.post = post
    self.slackHookURL = slackHookURL
  }
}
