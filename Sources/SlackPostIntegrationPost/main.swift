import Darwin
import Basic
import XcodeServerHelpersKit
import Foundation
import SPMUtility

// The first argument is always the executable, drop it
let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<Slack Hook URL> <options>",
                            overview: "Commandline helper to post Xcode server integration results to slack.\nReads Xcode servers environment variables and generates a slack post.")
let slackHook: PositionalArgument<String> = parser.add(positional: "<Slack Hook URL>", kind: String.self, usage: "The slack hook used to generate the post, e.g. https://hooks.slack.com/services/Txxxxxxxxx/Bxxxxxxxxx/Zxxxxxxxxx")
let hostname: OptionArgument<String> = parser.add(option: "--hostname", kind: String.self, usage: "Optional: The hostname of the Xcode server. Used to generate links in posts.")

@available(OSX 10.13, *)
public func processArguments(_ arguments: ArgumentParser.Result) throws {
  let post = try SlackPost(xcodeServerEnvironment: ApplicationEnvironment(), serverHostname: arguments.get(hostname))
  guard let slackURLString = arguments.get(slackHook), let slackURL = URL(string: slackURLString) else {
    throw ArgumentParserError.invalidValue(argument: "slackHookURL", error: .unknown(value: arguments.get(slackHook) ?? "missing"))
  }
  print("Posting to slack: \(String(data: try JSONEncoder().encode(post), encoding: .utf8) ?? "-")")
  let request = PostToSlack(post: post, slackHookURL: slackURL)


  let engine = NetworkService()
  var result: Result<String, XcodeServerHelpersError>? = nil
  let progress = engine.send(request) { inResult in
    result = inResult
  }

  let progressBar = PercentProgressAnimation(stream: stdoutStream, header: "Posting to slack...")
  _ = progress.observe(\Progress.fractionCompleted) { (progress, _) in
    progressBar.update(step: Int(progress.fractionCompleted * 100), total: 100, text: "")
  }
  // wait for the request
  while (result == nil) { sleep(1) }

  switch result {
  case .none:
    progressBar.complete(success: false)
    throw XcodeServerHelpersError.unknownError
  case .failure(let error)?:
    progressBar.complete(success: false)
    throw error
  case .success(let response)?:
    print("Successfully posted to Slack. Response: `\(response)`.")
    progressBar.complete(success: true)
  }
}

do {
  let parsedArguments = try parser.parse(arguments)
  if #available(OSX 10.13, *) {
    try processArguments(parsedArguments)
  } else {
    throw XcodeServerHelpersError.unsupportedMacOSVersion
  }
} catch let error as ArgumentParserError {
  fputs("Error: \(error.description)\n\n", stderr)
  parser.printUsage(on: stderrStream)
  exit(-2)
} catch let error as XcodeServerHelpersError {
  fputs("Error: \(error.localizedDescription)\n", stderr)
  exit(error.code)
} catch let error {
  fputs("Error: \(error.localizedDescription)\n", stderr)
  exit(-1)
}
