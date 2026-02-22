import Foundation
import Combine
import UserNotifications

@MainActor
class PrayerViewModel: ObservableObject {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var nextPrayer: PrayerTime?
    @Published var countdown: String = "00:00:00"
    @Published var nextPrayerProgress: Double = 0.0  // 0.0 to 1.0
    @Published var maghribCountdown: String = "00:00:00"  // Countdown to Maghrib
    @Published var fastingStatus: FastingStatus = .notFasting
    @Published var currentDate: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var skyTheme: SkyTheme = SkyTheme()
    
    // Glass mode
    @Published var isGlassMode: Bool = false

    private let service = PrayerService.shared
    private let cacheService = CacheService.shared
    private var countdownTimer: Timer?
    private var midnightTimer: Timer?

    var selectedCity: String {
        UserPreferences.shared.selectedCityName
    }

    init() {
        // Load preferences
        isGlassMode = UserPreferences.shared.isGlassMode
        skyTheme = SkyTheme(isGlassMode: isGlassMode)
        
        setupTimers()
        Task {
            await loadPrayerTimes()
        }
    }
    
    // MARK: - Preferences
    func toggleGlassMode() {
        isGlassMode.toggle()
        skyTheme = SkyTheme(isGlassMode: isGlassMode)
        UserPreferences.shared.isGlassMode = isGlassMode
    }
    
    // MARK: - Load Prayer Times
    func loadPrayerTimes(forceRefresh: Bool = false) async {
        print("🔄 loadPrayerTimes called, forceRefresh: \(forceRefresh)")
        isLoading = true
        errorMessage = nil
        
        do {
            let cityId = UserPreferences.shared.selectedCityId
            print("📍 Loading for cityId: \(cityId)")
            let scheduleData = try await service.fetchPrayerSchedule(cityId: cityId, forceRefresh: forceRefresh)
            
            guard let schedule = scheduleData.todaySchedule else {
                errorMessage = "Jadwal tidak tersedia"
                isLoading = false
                return
            }
            
            // Get timezone from city location (province)
            let prayerTimeZone = scheduleData.timeZone

            prayerTimes = PrayerTimeUtils.parsePrayerTimes(from: schedule, timeZone: prayerTimeZone)
            nextPrayer = PrayerTimeUtils.findNextPrayer(from: prayerTimes)
            fastingStatus = PrayerTimeUtils.detectFastingStatus(prayerTimes: prayerTimes)
            currentDate = PrayerTimeUtils.formatDate(Date())

            // Update city name from API response
            UserPreferences.shared.selectedCityName = scheduleData.displayName

            // Schedule notifications
            scheduleNotifications(timeZone: prayerTimeZone.timeZone)

            print("✅ Prayer times loaded successfully")
            
        } catch {
            errorMessage = "Gagal memuat jadwal: \(error.localizedDescription)"
            print("❌ Error loading prayer times: \(error)")
        }
        
        isLoading = false
        print("🏁 loadPrayerTimes completed")
    }
    
    // MARK: - Setup Timers
    private func setupTimers() {
        // Countdown timer (every second)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateCountdown()
            }
        }
        
        // Schedule midnight refresh
        scheduleMidnightRefresh()
    }
    
    // MARK: - Update Countdown
    private func updateCountdown() {
        // Update sky theme every tick
        skyTheme = SkyTheme(isGlassMode: isGlassMode)

        guard let next = nextPrayer else {
            countdown = "00:00:00"
            nextPrayerProgress = 0.0
            maghribCountdown = "00:00:00"
            return
        }

        countdown = PrayerTimeUtils.countdown(to: next.time)

        // Calculate progress between previous prayer and next prayer
        nextPrayerProgress = calculateProgress(to: next)

        // Update Maghrib countdown
        updateMaghribCountdown()

        // If countdown finished, find next prayer
        if next.time <= Date() {
            nextPrayer = PrayerTimeUtils.findNextPrayer(from: prayerTimes)
        }
    }

    // MARK: - Update Maghrib Countdown
    private func updateMaghribCountdown() {
        let now = Date()

        // Find Maghrib time
        guard let maghrib = prayerTimes.first(where: { $0.name == "Maghrib" }) else {
            maghribCountdown = "00:00:00"
            return
        }

        // Only show countdown if before Maghrib (start from 00:05 after API fetch)
        if now < maghrib.time {
            maghribCountdown = PrayerTimeUtils.countdown(to: maghrib.time)
        } else {
            maghribCountdown = "00:00:00"
        }
    }
    
    // MARK: - Calculate Progress
    private func calculateProgress(to next: PrayerTime) -> Double {
        let now = Date()
        
        // Find the previous prayer (the one before `next`)
        guard let nextIndex = prayerTimes.firstIndex(where: { $0.id == next.id }) else {
            return 0.0
        }
        
        let previousTime: Date
        if nextIndex > 0 {
            previousTime = prayerTimes[nextIndex - 1].time
        } else {
            // First prayer of the day — use midnight as start
            let calendar = Calendar.current
            previousTime = calendar.startOfDay(for: now)
        }
        
        let totalInterval = next.time.timeIntervalSince(previousTime)
        let elapsed = now.timeIntervalSince(previousTime)
        
        guard totalInterval > 0 else { return 0.0 }
        return min(max(elapsed / totalInterval, 0.0), 1.0)
    }
    
    // MARK: - Schedule Midnight Refresh
    private func scheduleMidnightRefresh() {
        // Use device calendar (User's local time)
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate next 00:05 local time
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 0
        components.minute = 5
        components.second = 0
        
        guard var targetDate = calendar.date(from: components) else { return }
        
        // If already past 00:05 today, schedule for tomorrow
        if targetDate <= now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        }
        
        let timeInterval = targetDate.timeIntervalSinceNow

        // Schedule one-time timer
        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.loadPrayerTimes(forceRefresh: true)
                // Reschedule for next day
                self?.scheduleMidnightRefresh()
            }
        }
    }
    
    // MARK: - Schedule Notifications
    func scheduleNotifications(timeZone: TimeZone) {
        guard let subuh = prayerTimes.first(where: { $0.name == "Subuh" })?.time,
              let maghrib = prayerTimes.first(where: { $0.name == "Maghrib" })?.time else {
            return
        }
        
        NotificationService.shared.schedulePrayerNotifications(
            subuhTime: subuh,
            maghribTime: maghrib,
            timeZone: timeZone
        )
    }

    // MARK: - Cleanup
    deinit {
        countdownTimer?.invalidate()
        midnightTimer?.invalidate()
    }
}
