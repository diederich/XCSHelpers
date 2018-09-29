// Created by Stephan Diederich on 29.09.2018.
// Copyright © 2018 Stephan Diederich. All rights reserved.
//

import Foundation

struct Post: Encodable {
  var text: String
}


// MARK: - Create slack post from Xcode Servers environment variables
extension Post {
  init(environment: Environment) throws {
    guard environment.isRunningServer else {
      throw SlackPostError.notRunningOnXcodeServer
    }
    text = "\(environment.XCS_BOT_NAME ?? "")"
  }
}
