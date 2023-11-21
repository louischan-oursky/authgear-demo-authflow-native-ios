import Foundation
import UIKit
import Authgear

class QueryPreparer: NSObject, URLSessionTaskDelegate {
    func prepareQuery() async throws -> (AuthgearExperimental.AuthenticationRequest, [URLQueryItem]) {
        let authRequest = try await UIApplication.shared.authgear.experimental.createAuthenticateRequest(
            redirectURI: "com.example.myapp://host/path",
            // Specify ui_locales so that any messages (email messages or sms) sent in this authflow
            // are in the user's preferred language.
            uiLocales: ["zh-HK"]
        ).get()
        let urlRequest = URLRequest(url: authRequest.url)

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil)
        let (_, urlResponse) = try await session.data(for: urlRequest)
        let httpURLResponse = urlResponse as! HTTPURLResponse
        let location = httpURLResponse.value(forHTTPHeaderField: "Location")!
        let redirectURL = URL(string: location)!
        let query = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false)!.queryItems!
        return (authRequest, query)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        return nil
    }
}

func createAuthflow(session: URLSession, query: [URLQueryItem]) async throws -> AuthgearResponse {
    var url = URL(string: ENDPOINT)!
    url.append(path: "/api/v1/authentication_flows")
    url.append(queryItems: query)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let requestBody: [String: Any] = [
        "type": "login",
        "name": "default"
    ]
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    let (data, _) = try await session.data(for: urlRequest)
    let decoder = JSONDecoder()
    let authgearResponse = try decoder.decode(AuthgearResponse.self, from: data)
    return authgearResponse
}

func inputAuthflow(session: URLSession, stateToken: String, input: [String: Any]) async throws -> AuthgearResponse {
    var url = URL(string: ENDPOINT)!
    url.append(path: "/api/v1/authentication_flows/states/input")
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let requestBody: [String: Any] = [
        "state_token": stateToken,
        "input": input
    ]
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    let (data, _) = try await session.data(for: urlRequest)
    let decoder = JSONDecoder()
    let authgearResponse = try decoder.decode(AuthgearResponse.self, from: data)
    return authgearResponse
}

func extractRedirectURI(session: URLSession, url: URL) async throws -> URL {
    // The url is /oauth2/content
    // which will return a 200 response with an HTML document
    //
    // <!DOCTYPE html>
    // <html>
    // <head>
    // <meta http-equiv="refresh" content="0;url={{ .redirect_uri }}" />
    // </head>
    // <body>
    // <script nonce="{{ $.CSPNonce }}">
    // window.location.href = "{{ .redirect_uri }}"
    // </script>
    // </body>
    // </html>
    //
    // We want to extract the redirecet URI because the redirect URI contains the authorization code
    // that we need to perform code exchange.

    let urlRequest = URLRequest(url: url)
    let (data, _) = try await session.data(for: urlRequest)
    let str = String(data: data, encoding: .utf8)!
    let regex = /content="0;url=(.*)"/
    let match = try regex.firstMatch(in: str)!
    let redirectURI = URL(string: String(match.1))
    return redirectURI!
}
