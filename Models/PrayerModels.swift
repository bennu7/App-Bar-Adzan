import Foundation

// MARK: - Prayer Time Model
struct PrayerTime: Identifiable {
    let id = UUID()
    let name: String
    let time: Date
    let icon: String
    let timeZone: String // e.g. "WIB"
    let timeZoneIdentifier: String // e.g. "Asia/Jakarta"
}

// MARK: - API Response Models
struct PrayerScheduleResponse: Codable {
    let status: Bool
    let data: PrayerScheduleData
}

struct PrayerScheduleData: Codable {
    let id: String
    let kabko: String
    let prov: String
    let jadwal: [String: PrayerSchedule]
    
    var todaySchedule: PrayerSchedule? {
        jadwal.values.first
    }
    
    var displayName: String {
        "\(kabko), \(prov)"
    }
    
    var timeZone: PrayerTimeZone {
        TimezoneMapper.getTimeZone(for: prov)
    }
}

struct PrayerSchedule: Codable {
    let tanggal: String
    let imsak: String
    let subuh: String
    let terbit: String
    let dhuha: String
    let dzuhur: String
    let ashar: String
    let maghrib: String
    let isya: String
}

// MARK: - Fasting Status
enum FastingStatus {
    case fasting(reason: String, emoji: String = "")
    case notFasting

    var isFasting: Bool {
        if case .fasting = self { return true }
        return false
    }

    var reason: String? {
        if case .fasting(let reason, _) = self { return reason }
        return nil
    }

    var emoji: String {
        if case .fasting(_, let emoji) = self { return emoji }
        return ""
    }
}
