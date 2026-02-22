import Foundation

class PrayerService {
    static let shared = PrayerService()
    
    private let apiClient = MyQuranAPIClient.shared
    private let cacheService = CacheService.shared
    
    // MARK: - Fetch Prayer Schedule
    func fetchPrayerSchedule(cityId: String, forceRefresh: Bool = false) async throws -> PrayerScheduleData {
        // Try cache first
        if !forceRefresh, let cached = cacheService.loadCache(for: cityId) {
            return cached
        }
        
        // Fetch from API
        let schedule = try await apiClient.fetchTodaySchedule(cityId: cityId)
        
        // Save to cache
        cacheService.saveCache(schedule, for: cityId)
        
        return schedule
    }
    
    // MARK: - Fetch Cities
    func fetchAllCities() async throws -> [City] {
        return try await apiClient.fetchAllCities()
    }
    
    // MARK: - Search Cities
    func searchCities(keyword: String) async throws -> [City] {
        return try await apiClient.searchCities(keyword: keyword)
    }
}
