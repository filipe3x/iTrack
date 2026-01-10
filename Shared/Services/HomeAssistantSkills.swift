//
//  HomeAssistantSkills.swift
//  iTrack
//
//  Models and registry helpers for Home Assistant service calls
//

import Foundation

/// Supported domains for grouping Home Assistant skills.
enum HomeAssistantSkillCategory: String, Codable, CaseIterable {
    case lighting
    case security
    case access
    case windows
}

/// Known service actions that align with Home Assistant service endpoints.
enum HomeAssistantServiceAction: String, Codable {
    case turnOn = "turn_on"
    case turnOff = "turn_off"
    case lock
    case unlock
    case openCover = "open_cover"
    case closeCover = "close_cover"
}

/// Identifier for the built-in skills the app supports out of the box.
enum HomeAssistantSkillIdentifier: String, Codable, CaseIterable, Hashable {
    case lightsOn
    case lightsOff
    case lockDoors
    case unlockDoors
    case openGarageDoor
    case closeGarageDoor
    case openWindows
    case closeWindows
}

/// Describes the Home Assistant service call required to fulfill a skill.
struct HomeAssistantServiceCall: Codable {
    /// Home Assistant domain (e.g. `light`, `lock`, `cover`).
    let domain: String
    /// Service action name (e.g. `turn_on`, `open_cover`).
    let service: HomeAssistantServiceAction
    /// Optional default entity ID to target when no override is provided.
    let defaultEntityId: String?
    /// Additional payload items to send along with the request.
    let parameters: [String: String]

    /// Merge the default payload with an optional entity override.
    func payload(entityIdOverride: String? = nil) -> [String: String] {
        var payload = parameters

        if let id = entityIdOverride ?? defaultEntityId {
            payload["entity_id"] = id
        }

        return payload
    }
}

/// Represents a Home Assistant skill that can be invoked from the app.
struct HomeAssistantSkill: Identifiable, Codable {
    let id: UUID
    let identifier: HomeAssistantSkillIdentifier
    let title: String
    let description: String
    let category: HomeAssistantSkillCategory
    let call: HomeAssistantServiceCall
    let requiresConfirmation: Bool

    init(
        id: UUID = UUID(),
        identifier: HomeAssistantSkillIdentifier,
        title: String,
        description: String,
        category: HomeAssistantSkillCategory,
        call: HomeAssistantServiceCall,
        requiresConfirmation: Bool = false
    ) {
        self.id = id
        self.identifier = identifier
        self.title = title
        self.description = description
        self.category = category
        self.call = call
        self.requiresConfirmation = requiresConfirmation
    }
}

/// Provides the built-in skills and an easy entry point for adding new ones.
struct HomeAssistantSkillRegistry {
    private(set) var skills: [HomeAssistantSkillIdentifier: HomeAssistantSkill]

    init(defaultEntityIds: [HomeAssistantSkillIdentifier: String] = HomeAssistantConfiguration.defaultEntityIds) {
        skills = [:]
        seedSkills(defaultEntityIds: defaultEntityIds)
    }

    /// Lookup a single skill definition.
    func skill(for identifier: HomeAssistantSkillIdentifier) -> HomeAssistantSkill? {
        return skills[identifier]
    }

    /// Ordered list of all available skills.
    func allSkills() -> [HomeAssistantSkill] {
        return HomeAssistantSkillIdentifier.allCases.compactMap { skills[$0] }
    }

    /// Internal helper to register the built-in set of skills.
    private mutating func seedSkills(defaultEntityIds: [HomeAssistantSkillIdentifier: String]) {
        skills[.lightsOn] = HomeAssistantSkill(
            identifier: .lightsOn,
            title: "Turn on lights",
            description: "Calls the Home Assistant light.turn_on service.",
            category: .lighting,
            call: HomeAssistantServiceCall(
                domain: "light",
                service: .turnOn,
                defaultEntityId: defaultEntityIds[.lightsOn],
                parameters: [:]
            )
        )

        skills[.lightsOff] = HomeAssistantSkill(
            identifier: .lightsOff,
            title: "Turn off lights",
            description: "Calls the Home Assistant light.turn_off service.",
            category: .lighting,
            call: HomeAssistantServiceCall(
                domain: "light",
                service: .turnOff,
                defaultEntityId: defaultEntityIds[.lightsOff],
                parameters: [:]
            )
        )

        skills[.lockDoors] = HomeAssistantSkill(
            identifier: .lockDoors,
            title: "Lock doors",
            description: "Calls the Home Assistant lock.lock service.",
            category: .security,
            call: HomeAssistantServiceCall(
                domain: "lock",
                service: .lock,
                defaultEntityId: defaultEntityIds[.lockDoors],
                parameters: [:]
            ),
            requiresConfirmation: true
        )

        skills[.unlockDoors] = HomeAssistantSkill(
            identifier: .unlockDoors,
            title: "Unlock doors",
            description: "Calls the Home Assistant lock.unlock service.",
            category: .security,
            call: HomeAssistantServiceCall(
                domain: "lock",
                service: .unlock,
                defaultEntityId: defaultEntityIds[.unlockDoors],
                parameters: [:]
            ),
            requiresConfirmation: true
        )

        skills[.openGarageDoor] = HomeAssistantSkill(
            identifier: .openGarageDoor,
            title: "Open garage door",
            description: "Calls the Home Assistant cover.open_cover service.",
            category: .access,
            call: HomeAssistantServiceCall(
                domain: "cover",
                service: .openCover,
                defaultEntityId: defaultEntityIds[.openGarageDoor],
                parameters: [:]
            )
        )

        skills[.closeGarageDoor] = HomeAssistantSkill(
            identifier: .closeGarageDoor,
            title: "Close garage door",
            description: "Calls the Home Assistant cover.close_cover service.",
            category: .access,
            call: HomeAssistantServiceCall(
                domain: "cover",
                service: .closeCover,
                defaultEntityId: defaultEntityIds[.closeGarageDoor],
                parameters: [:]
            )
        )

        skills[.openWindows] = HomeAssistantSkill(
            identifier: .openWindows,
            title: "Open windows",
            description: "Calls the Home Assistant cover.open_cover service for windows.",
            category: .windows,
            call: HomeAssistantServiceCall(
                domain: "cover",
                service: .openCover,
                defaultEntityId: defaultEntityIds[.openWindows],
                parameters: [:]
            )
        )

        skills[.closeWindows] = HomeAssistantSkill(
            identifier: .closeWindows,
            title: "Close windows",
            description: "Calls the Home Assistant cover.close_cover service for windows.",
            category: .windows,
            call: HomeAssistantServiceCall(
                domain: "cover",
                service: .closeCover,
                defaultEntityId: defaultEntityIds[.closeWindows],
                parameters: [:]
            )
        )
    }
}
