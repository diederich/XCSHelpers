import XCTest
import class Foundation.Bundle

enum TestError: Int, Error {
  case macOS13Required = 1
}

@available(OSX 10.13, *)
final class SlackPostIntegrationIntegrationPostTests: XCTestCase {
  var sut: Process!
  var errorOutputPipe = Pipe()
  var standardOutputPipe = Pipe()

  // MARK: - Setup
  override func setUp() {
    let fooBinary = productsDirectory.appendingPathComponent("SlackPostIntegrationPost")

    let process = Process()
    process.executableURL = fooBinary
    process.standardError = errorOutputPipe
    process.standardOutput = standardOutputPipe
    sut = process
  }

  // MARK: - Tests
  func testEmptyEnvironment() throws {
    sut.arguments = [ "https://slack.hook.url" ]
    try runProcess()

    XCTAssertEqual(sut.terminationStatus, 2)
    XCTAssertFalse(stringFromOutput(errorOutputPipe).isEmpty, "Should've printed to stderr")
  }

  // disabled - requires proper slack URL
  func disabled_testSuccessfulRun() throws {
    sut.arguments = [ "https://slack.hook.url", "--hostname", "minion.local"]
    sut.environment = [
      "XCS_XCODEBUILD_LOG": "/xxx/xcodebuild.log",
      "XCS_PRODUCT": "/xxx/Xbuddy.ipa",
      "XCS_PRIMARY_REPO_BRANCH": "master",
      "XCS_ERROR_COUNT": "0",
      "XCS_ANALYZER_WARNING_COUNT": "0",
      "XCS_TESTS_CHANGE": "-1",
      "XPC_SERVICE_NAME": "0",
      "XCS_ERROR_CHANGE": "0",
      "XCS_DERIVED_DATA_DIR": "/xxx/DerivedData",
      "XCS_ANALYZER_WARNING_CHANGE": "0",
      "XCS_WARNING_COUNT": "2",
      "XCS_TESTS_COUNT": "28",
      "XCS_OUTPUT_DIR": "/xxx/Integration-ec435d6b029240f17f72d78c1165aeac",
      "XCS_INTEGRATION_NUMBER": "56",
      "XCS_BOT_NAME": "TestBot",
      "XCS": "1",
      "XCS_WARNING_CHANGE": "0",
      "XCS_SOURCE_DIR": "/xxx/843075fd656bb8509177f6cd1d142896/Source",
      "XCS_INTEGRATION_RESULT": "warnings",
      "XCS_TEST_FAILURE_COUNT": "0",
      "XCS_INTEGRATION_ID": "ec435d6b029240f17f72d78c1165aeac",
      "XCS_BOT_ID": "843075fd656bb8509177f6cd1d142896",
      "XCS_BOT_TINY_ID": "0D7902C",
      "XCS_ARCHIVE": "/xxx/Integration-ec435d6b029240f17f72d78c1165aeac/Xbuddy.xcarchive",
      "XCS_TEST_FAILURE_CHANGE": "0",
      "XCS_INTEGRATION_TINY_ID": "91D6155",
      "XCS_PRIMARY_REPO_DIR": "/xxx/XCSBuilder/Bots/843075fd656bb8509177f6cd1d142896/Source/Xbuddy",
    ]
    try runProcess()

    XCTAssertEqual(sut.terminationStatus, 0)
    XCTAssertEqual(stringFromOutput(errorOutputPipe), "", "Should've not printed to stderr")
    let output = stringFromOutput(standardOutputPipe)
    XCTAssertTrue(output.contains("TestBot"), "Should've echoed botname to stdout")
  }

  // MARK: - Helpers

  /// Runs and waits for the process to exit
  func runProcess() throws {
    try sut.run()
    sut.waitUntilExit()
  }

  func stringFromOutput(_ pipe: Pipe) -> String {
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    return output ?? ""
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
    #else
    return Bundle.main.bundleURL
    #endif
  }

  static var allTests = [
    ("testEmptyEnvironment", testEmptyEnvironment),
    ]
}
