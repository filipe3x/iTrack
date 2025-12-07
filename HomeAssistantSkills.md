# Home Assistant skills

This app can call Home Assistant services through small, declarative "skills." The registry gives you a curated list of actions and makes it easy to add new ones without touching UI code.

## Built-in skills

The repository seeds the following standard skills:

| Skill | Domain/Service | Default entity key |
| --- | --- | --- |
| Lights on | `light.turn_on` | `.lightsOn` |
| Lights off | `light.turn_off` | `.lightsOff` |
| Lock doors | `lock.lock` | `.lockDoors` |
| Unlock doors | `lock.unlock` | `.unlockDoors` |
| Open garage door | `cover.open_cover` | `.openGarageDoor` |
| Close garage door | `cover.close_cover` | `.closeGarageDoor` |
| Open windows | `cover.open_cover` | `.openWindows` |
| Close windows | `cover.close_cover` | `.closeWindows` |

Defaults for these entity IDs live in `HomeAssistantConfiguration.defaultEntityIds`.

## Configuration

1. Create a long-lived access token in your Home Assistant user profile.
2. Set `HomeAssistantConfiguration.baseURLString` to your Home Assistant URL (for example, `http://homeassistant.local:8123`).
3. Store the token in `HomeAssistantConfiguration.longLivedToken` or inject it at runtime via your own secure storage.
4. Update `HomeAssistantConfiguration.defaultEntityIds` with your actual entity IDs so the app can invoke skills without callers providing overrides.

## Using a skill

```swift
let registry = HomeAssistantSkillRegistry()
let client = HomeAssistantClient()

if let unlock = registry.skill(for: .unlockDoors),
   let request = client.request(for: unlock) {
    // Send `request` with your networking stack (URLSession, Alamofire, etc.)
}
```

You can also override the target entity at call time:

```swift
let kitchenLights = registry.skill(for: .lightsOn)
let request = client.request(for: kitchenLights!, entityOverride: "light.kitchen")
```

## Adding a new skill

1. Add a new case to `HomeAssistantSkillIdentifier` in `Shared/Services/HomeAssistantSkills.swift`.
2. Register the skill inside `seedSkills(defaultEntityIds:)`, providing the domain, service action, and any default parameters.
3. (Optional) Add a default entity ID for your new identifier in `HomeAssistantConfiguration.defaultEntityIds`.
4. Update this document to list the new skill so others know how to use it.

Skills are decoupled from transport. Any networking client that accepts a `URLRequest` can consume the objects produced by `HomeAssistantClient`.
