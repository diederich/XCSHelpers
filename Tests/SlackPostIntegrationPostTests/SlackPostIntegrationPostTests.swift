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
    try runProcess()

    XCTAssertEqual(sut.terminationStatus, 1)
    XCTAssertFalse(stringFromOutput(errorOutputPipe).isEmpty, "Should've printed to stderr")
  }

  func testSuccessfulRun() throws {
    sut.environment = [
      "XCS" : "1",
      "XCS_BOT_NAME" : "TestBot"
    ]
    try runProcess()

    XCTAssertEqual(sut.terminationStatus, 0)
    XCTAssertTrue(stringFromOutput(errorOutputPipe).isEmpty, "Should've printed to stderr")
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
    ("testSuccessfulRun", testSuccessfulRun),
    ("testEmptyEnvironment", testEmptyEnvironment),
    ]
}
