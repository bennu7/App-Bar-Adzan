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
    
    // MARK: - Fasting Detection
    static func detectFastingStatus() -> FastingStatus {
        let calendar = Calendar.current
        
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let day = calendar.component(.day, from: now)
        
        // Monday or Thursday
        if weekday == 2 || weekday == 5 {
            return .fasting(reason: "Senin/Kamis")
        }
        
        // Ayyamul Bidh (13, 14, 15 Hijri)
        // Note: Ideally this should use Hijri calendar, but for MVP Gregorian mapping or Hijri lib is needed.
        // Assuming simple day check for now as placeholder or specific logic.
        if [13, 14, 15].contains(day) {
            return .fasting(reason: "Ayyamul Bidh")
        }
        
        return .notFasting
    }
    
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
