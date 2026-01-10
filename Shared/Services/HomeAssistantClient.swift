//
//  HomeAssistantClient.swift
//  iTrack
//
//  Lightweight helper to build Home Assistant service requests from skills
//

import Foundation

/// Minimal client helper for composing Home Assistant service requests.
struct HomeAssistantClient {
    let baseURL: URL
    let token: String
    let timeout: TimeInterval

    init(
        baseURL: URL? = URL(string: HomeAssistantConfiguration.baseURLString),
        token: String = HomeAssistantConfiguration.longLivedToken,
        timeout: TimeInterval = HomeAssistantConfiguration.requestTimeout
    ) {
        self.baseURL = baseURL ?? URL(fileURLWithPath: "/")
        self.token = token
        self.timeout = timeout
    }

    /// Build the URL used to call a given skill.
    private func endpoint(for call: HomeAssistantServiceCall) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = "/api/services/\(call.domain)/\(call.service.rawValue)"
        return components?.url
    }

    /// Returns a configured URLRequest for a skill and optional entity override.
    func request(for skill: HomeAssistantSkill, entityOverride: String? = nil) -> URLRequest? {
        guard let url = endpoint(for: skill.call) else { return nil }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let payload = skill.call.payload(entityIdOverride: entityOverride)

        if let body = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            request.httpBody = body
        }

        return request
    }
}
