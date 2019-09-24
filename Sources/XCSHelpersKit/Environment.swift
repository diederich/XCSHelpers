// Copied by Stephan Diederich on 29.09.2018.
// from https://gist.github.com/DougGregor/68259dd47d9711b27cbbfde3e89604e8

import Darwin

public protocol XcodeServerEnvironment {
  subscript(key: XcodeServerEnvironmentKey) -> String? { get }
}

public enum XcodeServerEnvironmentKey: String {
  case XCS
  //Xcode 7 and later
  //The value of this variable is always 1. A script can check this value to determine if it’s running in the context of Xcode Server.

  case XCS_BOT_NAME
  //Xcode 7 and later
  //The name of the bot being run.

  case XCS_BOT_ID
  //Xcode 7 and later
  //The ID of the bot. Bot IDs can be used in Xcode Server API requests.

  case XCS_BOT_TINY_ID
  //Xcode 7 and later
  //A short version of a bot ID. Some Xcode Server API requests use this information.

  case XCS_INTEGRATION_ID
  //Xcode 7 and later
  //The ID of the integration. Bot IDs can be used in Xcode Server API requests.

  case XCS_INTEGRATION_TINY_ID
  //Xcode 7 and later
  //A short version of an integration ID. Some Xcode Server API requests use this information.

  case XCS_INTEGRATION_NUMBER
  //Xcode 7 and later
  //The number of times the integration has been run.

  case XCS_INTEGRATION_RESULT
  //Xcode 7 and later
  //A string indicating the result of the integration, such as succeeded, test-failures, build-errors, and canceled. This variable is intended for use in post-integration trigger scripts.

  case XCS_SOURCE_DIR
  //Xcode 7 and later
  //The top-level directory containing source code repositories for Xcode Server. For the path to a repository itself, see XCS_PRIMARY_REPO_DIR.

  case XCS_OUTPUT_DIR
  //Xcode 7 and later
  //The top-level directory where resources, including logs and products, are stored during integration.

  case XCS_DERIVED_DATA_DIR
  //Xcode 7 and later
  //The derived data directory. Xcode Server builds in a non-standard location, so this directory is bot-specific.

  case XCS_XCODEBUILD_LOG
  //Xcode 7 and later
  //The path to an output file produced by the xcodebuild commands run during the integration.

  case XCS_ARCHIVE
  //Xcode 7 and later
  //The path to the .xarchive file, if archiving occurred during the integration.

  case XCS_PRODUCT
  //Xcode 7 and later
  //The path to the .app, .ipa, or .package file, if a product was exported from an archive during the integration.

  case XCS_ERROR_COUNT
  //Xcode 7 and later
  //The total number of errors encountered during the integration.

  case XCS_ERROR_CHANGE
  //Xcode 7 and later
  //The change in error count since the previous integration. This value can be negative.

  case XCS_WARNING_COUNT
  //Xcode 7 and later
  //The total number of warnings encountered during the integration.

  case XCS_WARNING_CHANGE
  //Xcode 7 and later
  //The change in warning count since the previous integration. This value can be negative.

  case XCS_ANALYZER_WARNING_COUNT
  //Xcode 7 and later
  //The total number of static analyzer warnings encountered during the integration.

  case XCS_ANALYZER_WARNING_CHANGE
  //Xcode 7 and later
  //The change in static analyzer warning count since the previous integration. This value can be negative.

  case XCS_TEST_FAILURE_COUNT
  //Xcode 7 and later
  //The total number of test failures encountered during the integration.

  case XCS_TEST_FAILURE_CHANGE
  //Xcode 7 and later
  //The change in test failure count since the previous integration. This value can be negative.

  case XCS_TESTS_COUNT
  //Xcode 7 and later
  //The total number of tests performed by the integration.

  case XCS_TESTS_CHANGE
  //Xcode 7 and later
  //The change in test count since the previous integration. This value can be negative.

  case XCS_THINNED_PRODUCTS_PLIST
  //Xcode 8 and later
  //The path to a property list file (.plist) describing thinned .ipa files exported and their corresponding variants. This property list file only exists when thinning is performed.

  case XCS_THINNED_PRODUCTS_PATH
  //Xcode 8 and later
  //The directory containing any thinned .ipa files exported during the integration.

  case XCS_PRIMARY_REPO_DIR
  //Xcode 8 and later
  //The path to the source code repository for the Xcode project or workspace being integrated. For the parent directory containing the source code repositories for Xcode Server, see XCS_SOURCE_DIR.

  case XCS_PRIMARY_REPO_BRANCH
  //Xcode 8 and later
  //The branch of the primary source code repository used to check out the project or workspace being integrated. Only used when checking out a branch.

  case XCS_PRIMARY_REPO_TAG
  //Xcode 8 and later
  //The tag of the primary source code repository used to check out the project or workspace being integrated. Only used when checking out a tag.

  case XCS_PRIMARY_REPO_REVISION
}

@dynamicMemberLookup
public struct ApplicationEnvironment {
  public init() {}

  public subscript(dynamicMember name: String) -> String? {
    get {
      guard let value = getenv(name) else { return nil }

      return String(validatingUTF8: value)
    }

    nonmutating set {
      if let value = newValue {
        setenv(name, value, /*overwrite:*/ 1)
      } else {
        unsetenv(name)
      }
    }
  }
}

extension ApplicationEnvironment: XcodeServerEnvironment {
  public subscript(key: XcodeServerEnvironmentKey) -> String? {
    return self[dynamicMember: key.rawValue]
  }
}

/// Easy creation via dictionary for testing
public struct DictionaryEnvironment: ExpressibleByDictionaryLiteral, XcodeServerEnvironment {
  public subscript(key: XcodeServerEnvironmentKey) -> String? {
    return dictionary[key.rawValue]
  }

  var dictionary: Dictionary<String, String>

  public init(dictionaryLiteral elements: (String, String)...) {
    var dict = Dictionary<String, String>()
    for (key, value) in elements {
      dict[key] = value
    }
    dictionary = dict
  }
}
