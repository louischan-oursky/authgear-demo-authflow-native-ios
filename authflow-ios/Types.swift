import Foundation
import Authgear

struct FlowResponse: Codable {
    let stateToken: String
    let type: String
    let name: String
    let action: FlowAction

    enum CodingKeys: String, CodingKey {
        case stateToken = "state_token"
        case type = "type"
        case name = "name"
        case action = "action"
    }
}

struct FlowAction: Codable {
    let type: String
    let identification: String?
    let authentication: String?
    let data: JSON
}

struct AuthgearResponse: Codable {
    let result: FlowResponse?
    let error: AuthgearErrorJSON?
}

struct AuthgearErrorJSON: Codable {
    let name: String
    let message: String
    let reason: String
    let info: JSON?
}
