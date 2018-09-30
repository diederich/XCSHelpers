import XCTest
import class Foundation.Bundle
@testable import XcodeServerHelpersKit

final class SlackPostTests: XCTestCase {

  // MARK: - Setup
  override func setUp() {
  }

  // MARK: - Tests
  func testBotNameAppearsInTitle() throws {
    let post = try SlackPost(xcodeServerEnvironment: defaultEnvironment)

    guard let attachment = post.attachments.first else {
      XCTFail("Must have attachments")
      return
    }

    XCTAssertTrue(attachment.title.contains("Xbuddy CI"))
  }

  func testLinks() throws {
    let post = try SlackPost(xcodeServerEnvironment: defaultEnvironment, serverHostname: "myserver.somewhere.com")
    guard let attachment = post.attachments.first else {
      XCTFail("Must have attachments")
      return
    }

    XCTAssertNotNil(attachment.title_link, "Failed to create link")
  }

  var defaultEnvironment: DictionaryEnvironment {
    return [
      "XCS_XCODEBUILD_LOG": "/xxx/xcodebuild.log",
      "XCS_PRODUCT": "/xxx/Xbuddy.ipa",
      "XCS_PRIMARY_REPO_BRANCH": "master",
      "XCS_ERROR_COUNT": "0",
      "XCS_ANALYZER_WARNING_COUNT": "0",
      "XCS_TESTS_CHANGE": "0",
      "XPC_SERVICE_NAME": "0",
      "XCS_ERROR_CHANGE": "0",
      "XCS_DERIVED_DATA_DIR": "/xxx/DerivedData",
      "XCS_ANALYZER_WARNING_CHANGE": "0",
      "XCS_WARNING_COUNT": "2",
      "XCS_TESTS_COUNT": "28",
      "XCS_OUTPUT_DIR": "/xxx/Integration-ec435d6b029240f17f72d78c1165aeac",
      "XCS_INTEGRATION_NUMBER": "56",
      "XCS_BOT_NAME": "Xbuddy CI",
      "XCS": "1",
      "XCS_WARNING_CHANGE": "0",
      "XCS_SOURCE_DIR": "/xxx/843075fd656bb8509177f6cd1d142896/Source",
      "XCS_INTEGRATION_RESULT": "warnings",
      "XCS_TEST_FAILURE_COUNT": "0",
      "XCS_INTEGRATION_ID": "ec435d6b029240f17f72d78c1165aeac",
      "XCS_BOT_TINY_ID": "0D7902C",
      "XCS_BOT_ID": "843075fd656bb8509177f6cd1d142896",
      "XCS_ARCHIVE": "/xxx/Integration-ec435d6b029240f17f72d78c1165aeac/Xbuddy.xcarchive",
      "XCS_TEST_FAILURE_CHANGE": "0",
      "XCS_INTEGRATION_TINY_ID": "91D6155",
      "XCS_PRIMARY_REPO_DIR": "/xxx/XCSBuilder/Bots/843075fd656bb8509177f6cd1d142896/Source/Xbuddy",
    ]  }

  static var allTests = [
    ("testEmptyEnvironment", testBotNameAppearsInTitle),
    ]
}
