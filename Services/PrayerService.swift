import Foundation
import UserNotifications

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

// MARK: - Notification Service
class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    // Notification IDs
    private let sahurEndingId = "sahur_ending"
    private let bukaSoonId = "buka_soon"
    private let bukaNowId = "buka_now"
    
    init() {
        // Request permission on init
        requestPermission()
    }
    
    // MARK: - Request Permission
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
                return
            }
            print("✅ Notification permission: \(granted ? "granted" : "denied")")
        }
    }
    
    // MARK: - Schedule Notifications
    func schedulePrayerNotifications(subuhTime: Date, maghribTime: Date, timeZone: TimeZone) {
        // Check if notifications are enabled
        if !UserPreferences.shared.isNotificationEnabled {
            cancelAllNotifications()
            return
        }
        
        // Cancel all pending notifications first
        cancelAllNotifications()
        
        // Schedule 5 minutes before Subuh (Sahur ending soon)
        scheduleNotification(
            id: sahurEndingId,
            title: "⏰ Sahur Segera Berakhir",
            body: "Waktu sahur tinggal 5 menit lagi. Jangan lupa niat puasa!",
            fireDate: subuhTime.addingTimeInterval(-5 * 60),
            timeZone: timeZone
        )
        
        // Schedule 5 minutes before Maghrib (Buka soon)
        scheduleNotification(
            id: bukaSoonId,
            title: "🌅 Buka Puasa Segera",
            body: "Waktu berbuka tinggal 5 menit lagi. Siapkan takjil!",
            fireDate: maghribTime.addingTimeInterval(-5 * 60),
            timeZone: timeZone
        )
        
        // Schedule on-time Maghrib (Buka now!)
        scheduleNotification(
            id: bukaNowId,
            title: "🍽️ Waktu Berbuka Telah Tiba",
            body: "Selamat berbuka puasa! Semoga puasanya berkah.",
            fireDate: maghribTime,
            timeZone: timeZone
        )
    }
    
    // MARK: - Schedule Single Notification
    private func scheduleNotification(
        id: String,
        title: String,
        body: String,
        fireDate: Date,
        timeZone: TimeZone
    ) {
        // Don't schedule if fire date is in the past
        if fireDate <= Date() {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var cal = calendar
        cal.timeZone = timeZone
        
        let components = cal.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification \(id): \(error)")
            } else {
                print("✅ Scheduled notification \(id) at \(fireDate)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")
    }
    
    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // MARK: - Check Permission
    func hasPermission() -> Bool {
        var granted = false
        let group = DispatchGroup()
        group.enter()
        
        center.getNotificationSettings { settings in
            granted = settings.authorizationStatus == .authorized
            group.leave()
        }
        
        group.wait()
        return granted
    }
}
