import Darwin
import Basic

do {
  let post = try Post(environment: Environment())
  print(post.text)
  
} catch {
  fputs("Error: \(error.localizedDescription)\n", stderr)
  if let ourError = error as? SlackPostError {
    exit(Int32(ourError.rawValue))
  } else {
    exit(-1)
  }
}
