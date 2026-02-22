import Foundation

class PrayerTimeUtils {
    // MARK: - Parse Prayer Times
    static func parsePrayerTimes(from schedule: PrayerSchedule, timeZone: PrayerTimeZone) -> [PrayerTime] {
        let prayers = [
            ("Subuh", schedule.subuh, "🌅"),
            ("Dzuhur", schedule.dzuhur, "☀️"),
            ("Ashar", schedule.ashar, "🌤"),
            ("Maghrib", schedule.maghrib, "🌇"),
            ("Isya", schedule.isya, "🌙")
        ]
        
        // Extract date from tanggal string (format: "Minggu, 22/02/2026")
        let dateString = extractDate(from: schedule.tanggal)
        
        return prayers.compactMap { name, timeString, icon in
            guard let date = parseTime(timeString, dateString: dateString, timeZone: timeZone) else { return nil }
            return PrayerTime(name: name, time: date, icon: icon, timeZone: timeZone.rawValue, timeZoneIdentifier: timeZone.identifier)
        }
    }
    
    // MARK: - Extract Date from Tanggal String
    private static func extractDate(from tanggal: String) -> String {
        // Input: "Minggu, 22/02/2026"
        // Output: "2026-02-22"
        let components = tanggal.split(separator: ",").last?.trimmingCharacters(in: .whitespaces) ?? ""
        let parts = components.split(separator: "/")
        guard parts.count == 3 else { return "" }
        return "\(parts[2])-\(parts[1])-\(parts[0])"
    }
    
    // MARK: - Parse Time String
    static func parseTime(_ timeString: String, dateString: String, timeZone: PrayerTimeZone) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = timeZone.timeZone
        return formatter.date(from: "\(dateString) \(timeString)")
    }
    
    // MARK: - Find Next Prayer
    static func findNextPrayer(from times: [PrayerTime]) -> PrayerTime? {
        let now = Date()
        return times.first { $0.time > now }
    }
    
    // MARK: - Calculate Countdown
    static func countdown(to date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return "00:00:00" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Fasting Detection (Ramadan Mode)
    static func detectFastingStatus(prayerTimes: [PrayerTime]) -> FastingStatus {
        let now = Date()
        
        // Find Subuh, Maghrib, and Isya times
        let subuhTime = prayerTimes.first(where: { $0.name == "Subuh" })?.time
        let maghribTime = prayerTimes.first(where: { $0.name == "Maghrib" })?.time
        let isyaTime = prayerTimes.first(where: { $0.name == "Isya" })?.time
        
        // Guard: all prayer times must be available
        guard let subuh = subuhTime, let maghrib = maghribTime, let isya = isyaTime else {
            return .notFasting
        }
        
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: midnight)!.addingTimeInterval(-1)
        
        // 00:00 - Subuh: Selamat Sahur 🌙
        if now < subuh {
            return .fasting(reason: "Selamat Sahur", emoji: "🌙")
        }
        
        // Subuh - Maghrib: Selamat Berpuasa ☀️
        if now < maghrib {
            return .fasting(reason: "Selamat Berpuasa", emoji: "☀️")
        }
        
        // Maghrib - Isya: Selamat Berbuka 🍽️
        if now < isya {
            return .fasting(reason: "Selamat Berbuka", emoji: "🍽️")
        }
        
        // Isya - 23:59: Selamat Tarawih 🕌
        if now < endOfDay {
            return .fasting(reason: "Selamat Tarawih", emoji: "🕌")
        }
        
        // Fallback (should not reach here)
        return .notFasting
    }

    // MARK: - Fasting Detection (Senin/Kamis) - DISABLED FOR RAMADAN
    // Uncomment after Ramadan if needed
    /*
    static func detectFastingStatusSeninKamis() -> FastingStatus {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        
        // Monday or Thursday
        if weekday == 2 || weekday == 5 {
            return .fasting(reason: "Senin/Kamis")
        }
        
        // Ayyamul Bidh (13, 14, 15 Hijri)
        // Note: This should use Hijri calendar for accurate calculation
        let day = calendar.component(.day, from: now)
        if [13, 14, 15].contains(day) {
            return .fasting(reason: "Ayyamul Bidh")
        }
        
        return .notFasting
    }
    */
    
    // MARK: - Format Date
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
        // Use device locale and timezone for display date
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
    
    // MARK: - Check if Midnight Passed
    static func shouldRefreshAtMidnight(lastFetchDate: Date?) -> Bool {
        guard let lastFetch = lastFetchDate else { return true }
        
        let calendar = Calendar.current
        // Use device calendar to decide refresh time
        
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // Check if it's past 00:05
        guard currentHour == 0 && currentMinute >= 5 else { return false }
        
        // Check if last fetch was yesterday
        return !calendar.isDate(lastFetch, inSameDayAs: now)
    }
}
