//
//  HomeAssistantConfiguration.swift
//  iTrack
//
//  Default connection and entity configuration for Home Assistant skills
//

import Foundation

/// Configuration values for connecting to a Home Assistant instance and
/// providing sensible defaults for common skills.
struct HomeAssistantConfiguration {
    /// Base URL to the Home Assistant instance (e.g. "http://homeassistant.local:8123").
    /// This is used by `HomeAssistantClient` when building service requests.
    static var baseURLString: String = "http://homeassistant.local:8123"

    /// Long-lived access token created in the Home Assistant user profile.
    /// Keep this empty or move it to a secure store until you have a real token.
    static var longLivedToken: String = ""

    /// Optional timeout for service requests (in seconds).
    static var requestTimeout: TimeInterval = 8.0

    /// Default entity IDs for the built-in skills.
    /// Provide your own values to avoid having to supply entity IDs at call time.
    static var defaultEntityIds: [HomeAssistantSkillIdentifier: String] = [
        .lightsOn: "light.bedroom",
        .lightsOff: "light.bedroom",
        .lockDoors: "lock.front_door",
        .unlockDoors: "lock.front_door",
        .openGarageDoor: "cover.garage",
        .closeGarageDoor: "cover.garage",
        .openWindows: "cover.bedroom_window",
        .closeWindows: "cover.bedroom_window"
    ]
}
