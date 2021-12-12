import XCSHelpersKit
import Foundation
import ArgumentParser

//@main
struct SlackPostCommand: ParsableCommand {
    @Option(help: "Optional: The hostname of the Xcode server. Used to generate links in posts.")
    var hostname: String

    @Argument(help: "The slack hook used to generate the post, e.g. https://hooks.slack.com/services/Txxxxxxxxx/Bxxxxxxxxx/Zxxxxxxxxx")
    var slackURLString: String

    mutating func run() throws {
        let post = try SlackPost(xcodeServerEnvironment: ApplicationEnvironment(), serverHostname: hostname)
        let slackURL = URL(string: slackURLString)!

        print("Posting to slack: \(String(data: try JSONEncoder().encode(post), encoding: .utf8) ?? "-")")
        let request = PostToSlack(post: post, slackHookURL: slackURL)

        let engine = NetworkService()
        var result: Result<String, XCSHelpersError>? = nil
        let progress = engine.send(request) { inResult in
            result = inResult
        }

        // wait for the request
        while (result == nil) { sleep(1) }

        switch result {
        case .none:
            throw XCSHelpersError.unknownError
        case .failure(let error)?:
            throw error
        case .success(let response)?:
            print("Successfully posted to Slack. Response: `\(response)`.")
        }
    }
}

