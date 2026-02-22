import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    private let selectedCityIdKey = "selectedCityId"
    private let selectedCityNameKey = "selectedCityName"
    
    var selectedCityId: String {
        get { defaults.string(forKey: selectedCityIdKey) ?? "1301" } // Default: Jakarta
        set { defaults.set(newValue, forKey: selectedCityIdKey) }
    }
    
    var selectedCityName: String {
        get { defaults.string(forKey: selectedCityNameKey) ?? "Jakarta, DKI Jakarta" }
        set { defaults.set(newValue, forKey: selectedCityNameKey) }
    }
    
    func setCity(id: String, name: String) {
        selectedCityId = id
        selectedCityName = name
    }
}
