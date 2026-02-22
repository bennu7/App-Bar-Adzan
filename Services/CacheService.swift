import Foundation

class CacheService {
    static let shared = CacheService()
    private let defaults = UserDefaults.standard
    
    private let cacheKey = "prayerScheduleCache"
    private let cacheDateKey = "prayerScheduleCacheDate"
    private let cacheCityIdKey = "prayerScheduleCacheCityId"
    
    // MARK: - Save Cache
    func saveCache(_ schedule: PrayerScheduleData, for cityId: String) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: cacheKey)
            defaults.set(Date(), forKey: cacheDateKey)
            defaults.set(cityId, forKey: cacheCityIdKey)
        }
    }
    
    // MARK: - Load Cache
    func loadCache(for cityId: String) -> PrayerScheduleData? {
        guard let data = defaults.data(forKey: cacheKey),
              let cachedCityId = defaults.string(forKey: cacheCityIdKey),
              cachedCityId == cityId,
              isCacheValid() else {
            return nil
        }
        
        return try? JSONDecoder().decode(PrayerScheduleData.self, from: data)
    }
    
    // MARK: - Check Cache Validity
    private func isCacheValid() -> Bool {
        guard let cacheDate = defaults.object(forKey: cacheDateKey) as? Date else {
            return false
        }
        
        // Use current calendar (device time) for cache validity check
        let calendar = Calendar.current
        return calendar.isDateInToday(cacheDate)
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        defaults.removeObject(forKey: cacheKey)
        defaults.removeObject(forKey: cacheDateKey)
        defaults.removeObject(forKey: cacheCityIdKey)
    }
    
    // MARK: - Get Last Fetch Date
    func getLastFetchDate() -> Date? {
        return defaults.object(forKey: cacheDateKey) as? Date
    }
}
