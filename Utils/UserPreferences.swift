import Foundation

class UserPreferences {
    static let shared = UserPreferences()

    private let defaults = UserDefaults.standard
    private let selectedCityIdKey = "selectedCityId"
    private let selectedCityNameKey = "selectedCityName"
    private let isGlassModeKey = "isGlassMode"
    private let isNotificationEnabledKey = "isNotificationEnabled"

    var selectedCityId: String {
        get { defaults.string(forKey: selectedCityIdKey) ?? "1301" } // Default: Jakarta
        set { defaults.set(newValue, forKey: selectedCityIdKey) }
    }

    var selectedCityName: String {
        get { defaults.string(forKey: selectedCityNameKey) ?? "Jakarta, DKI Jakarta" }
        set { defaults.set(newValue, forKey: selectedCityNameKey) }
    }
    
    // Glass mode setting
    var isGlassMode: Bool {
        get { defaults.object(forKey: isGlassModeKey) as? Bool ?? false }
        set { defaults.set(newValue, forKey: isGlassModeKey) }
    }
    
    // Notification settings
    var isNotificationEnabled: Bool {
        get { defaults.object(forKey: isNotificationEnabledKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: isNotificationEnabledKey) }
    }

    func setCity(id: String, name: String) {
        selectedCityId = id
        selectedCityName = name
    }
}
