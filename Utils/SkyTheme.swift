import SwiftUI

// MARK: - Sky Period
enum SkyPeriod: String, CaseIterable {
    case dawn      // 04:00 - 06:00  (Subuh)
    case morning   // 06:00 - 10:00  (Pagi)
    case midday    // 10:00 - 14:00  (Siang)
    case afternoon // 14:00 - 16:30  (Sore awal)
    case sunset    // 16:30 - 18:30  (Sore/Maghrib)
    case evening   // 18:30 - 20:00  (Petang)
    case night     // 20:00 - 04:00  (Malam)

    static func current(at date: Date = Date()) -> SkyPeriod {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let time = Double(hour) + Double(minute) / 60.0

        switch time {
        case 4.0..<6.0:    return .dawn
        case 6.0..<10.0:   return .morning
        case 10.0..<14.0:  return .midday
        case 14.0..<16.5:  return .afternoon
        case 16.5..<18.5:  return .sunset
        case 18.5..<20.0:  return .evening
        default:           return .night
        }
    }
}

// MARK: - Sky Theme
struct SkyTheme {
    let period: SkyPeriod
    let isGlassMode: Bool

    init(at date: Date = Date(), isGlassMode: Bool = false) {
        self.period = SkyPeriod.current(at: date)
        self.isGlassMode = isGlassMode
    }
    
    init(period: SkyPeriod, isGlassMode: Bool = false) {
        self.period = period
        self.isGlassMode = isGlassMode
    }
    
    // MARK: - Gradient Background
    var skyGradient: LinearGradient {
        LinearGradient(
            colors: isGlassMode ? glassGradientColors : gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var gradientColors: [Color] {
        switch period {
        case .dawn:
            return [
                Color(red: 0.15, green: 0.15, blue: 0.35),  // deep indigo top
                Color(red: 0.45, green: 0.30, blue: 0.50),  // purple mid
                Color(red: 0.85, green: 0.55, blue: 0.40),  // warm horizon
            ]
        case .morning:
            return [
                Color(red: 0.55, green: 0.75, blue: 0.95),  // soft blue
                Color(red: 0.75, green: 0.88, blue: 1.00),  // light blue
                Color(red: 0.95, green: 0.92, blue: 0.85),  // warm white
            ]
        case .midday:
            return [
                Color(red: 0.45, green: 0.70, blue: 0.95),  // clear blue
                Color(red: 0.70, green: 0.85, blue: 0.98),  // sky blue
                Color(red: 0.92, green: 0.94, blue: 0.96),  // warm white
            ]
        case .afternoon:
            return [
                Color(red: 0.50, green: 0.70, blue: 0.90),  // blue
                Color(red: 0.80, green: 0.78, blue: 0.70),  // warm
                Color(red: 0.95, green: 0.85, blue: 0.70),  // golden
            ]
        case .sunset:
            return [
                Color(red: 0.30, green: 0.35, blue: 0.60),  // dusky blue
                Color(red: 0.85, green: 0.50, blue: 0.40),  // orange
                Color(red: 0.95, green: 0.70, blue: 0.35),  // golden horizon
            ]
        case .evening:
            return [
                Color(red: 0.12, green: 0.12, blue: 0.30),  // deep blue
                Color(red: 0.25, green: 0.20, blue: 0.45),  // purple
                Color(red: 0.50, green: 0.30, blue: 0.45),  // dusky rose
            ]
        case .night:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.15),  // near black
                Color(red: 0.10, green: 0.10, blue: 0.25),  // deep navy
                Color(red: 0.15, green: 0.12, blue: 0.30),  // dark purple
            ]
        }
    }
    
    private var glassGradientColors: [Color] {
        switch period {
        case .dawn:
            return [
                Color(red: 0.15, green: 0.15, blue: 0.35).opacity(0.3),
                Color(red: 0.45, green: 0.30, blue: 0.50).opacity(0.2),
                Color(red: 0.85, green: 0.55, blue: 0.40).opacity(0.15),
            ]
        case .morning:
            return [
                Color(red: 0.55, green: 0.75, blue: 0.95).opacity(0.25),
                Color(red: 0.75, green: 0.88, blue: 1.00).opacity(0.15),
                Color(red: 0.95, green: 0.92, blue: 0.85).opacity(0.1),
            ]
        case .midday:
            return [
                Color(red: 0.45, green: 0.70, blue: 0.95).opacity(0.25),
                Color(red: 0.70, green: 0.85, blue: 0.98).opacity(0.15),
                Color(red: 0.92, green: 0.94, blue: 0.96).opacity(0.1),
            ]
        case .afternoon:
            return [
                Color(red: 0.50, green: 0.70, blue: 0.90).opacity(0.25),
                Color(red: 0.80, green: 0.78, blue: 0.70).opacity(0.15),
                Color(red: 0.95, green: 0.85, blue: 0.70).opacity(0.1),
            ]
        case .sunset:
            return [
                Color(red: 0.30, green: 0.35, blue: 0.60).opacity(0.3),
                Color(red: 0.85, green: 0.50, blue: 0.40).opacity(0.2),
                Color(red: 0.95, green: 0.70, blue: 0.35).opacity(0.15),
            ]
        case .evening:
            return [
                Color(red: 0.12, green: 0.12, blue: 0.30).opacity(0.3),
                Color(red: 0.25, green: 0.20, blue: 0.45).opacity(0.2),
                Color(red: 0.50, green: 0.30, blue: 0.45).opacity(0.15),
            ]
        case .night:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.15).opacity(0.3),
                Color(red: 0.10, green: 0.10, blue: 0.25).opacity(0.2),
                Color(red: 0.15, green: 0.12, blue: 0.30).opacity(0.15),
            ]
        }
    }
    
    // MARK: - Text Colors
    var primaryTextColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color(red: 0.15, green: 0.15, blue: 0.20)
        case .dawn, .sunset:
            return .white
        case .evening, .night:
            return Color(red: 0.92, green: 0.92, blue: 0.95)
        }
    }
    
    var secondaryTextColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color(red: 0.35, green: 0.35, blue: 0.45)
        case .dawn, .sunset:
            return Color(white: 0.85)
        case .evening, .night:
            return Color(red: 0.65, green: 0.65, blue: 0.75)
        }
    }
    
    // MARK: - Card Colors
    var cardBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.white.opacity(0.25)
        case .dawn, .sunset:
            return Color.white.opacity(0.12)
        case .evening, .night:
            return Color.white.opacity(0.06)
        }
    }

    var cardBorder: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.white.opacity(0.5)
        case .dawn, .sunset:
            return Color.white.opacity(0.15)
        case .evening, .night:
            return Color.white.opacity(0.1)
        }
    }

    // MARK: - Accent / Next Prayer Highlight
    var accentColor: Color {
        switch period {
        case .dawn:      return Color(red: 0.95, green: 0.70, blue: 0.45)  // warm amber
        case .morning:   return Color(red: 0.20, green: 0.55, blue: 0.90)  // fresh blue
        case .midday:    return Color(red: 0.15, green: 0.50, blue: 0.85)  // sky blue
        case .afternoon: return Color(red: 0.85, green: 0.60, blue: 0.20)  // golden
        case .sunset:    return Color(red: 0.95, green: 0.65, blue: 0.30)  // orange
        case .evening:   return Color(red: 0.70, green: 0.55, blue: 0.90)  // lavender
        case .night:     return Color(red: 0.55, green: 0.50, blue: 0.90)  // soft purple
        }
    }

    var nextPrayerCardBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return accentColor.opacity(0.20)
        default:
            return accentColor.opacity(0.25)
        }
    }

    var nextPrayerBorder: Color {
        accentColor.opacity(0.6)
    }

    var nextPrayerShadowColor: Color {
        accentColor.opacity(0.4)
    }

    var iconPillBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.white.opacity(0.5)
        default:
            return accentColor.opacity(0.2)
        }
    }

    var timeBadgeBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.black.opacity(0.08)
        default:
            return Color.white.opacity(0.15)
        }
    }

    var timeBadgeTextColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color(red: 0.15, green: 0.15, blue: 0.20)
        default:
            return .white
        }
    }
    
    // MARK: - Progress Bar
    var progressTrackColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.black.opacity(0.08)
        default:
//            return Color.white.opacity(0.10)
            return Color.white.opacity(0.25)
        }
    }
    
    var progressFillColor: Color {
        accentColor
    }
    
    // MARK: - Button Colors
    var buttonBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.black.opacity(0.06)
        default:
            return Color.white.opacity(0.10)
        }
    }
    
    var buttonHoverBackground: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.black.opacity(0.10)
        default:
            return Color.white.opacity(0.18)
        }
    }
    
    // MARK: - Divider
    var dividerColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color.black.opacity(0.08)
        default:
            return Color.white.opacity(0.10)
        }
    }
    
    // MARK: - Fasting Badge
    var fastingBadgeColor: Color {
        switch period {
        case .morning, .midday, .afternoon:
            return Color(red: 0.15, green: 0.65, blue: 0.35)
        default:
            return Color(red: 0.30, green: 0.80, blue: 0.50)
        }
    }
    
    // MARK: - Sky Icon
    var skyEmoji: String {
        switch period {
        case .dawn:      return "🌅"
        case .morning:   return "☀️"
        case .midday:    return "🌤"
        case .afternoon: return "⛅"
        case .sunset:    return "🌇"
        case .evening:   return "🌆"
        case .night:     return "🌙"
        }
    }
}

// MARK: - Environment Key
private struct SkyThemeKey: EnvironmentKey {
    static let defaultValue = SkyTheme()
}

extension EnvironmentValues {
    var skyTheme: SkyTheme {
        get { self[SkyThemeKey.self] }
        set { self[SkyThemeKey.self] = newValue }
    }
}

// MARK: - SkyPeriod Emoji Extension
extension SkyPeriod {
    var emoji: String {
        switch self {
        case .dawn:      return "🌅"
        case .morning:   return "☀️"
        case .midday:    return "🌤"
        case .afternoon: return "⛅"
        case .sunset:    return "🌇"
        case .evening:   return "🌆"
        case .night:     return "🌙"
        }
    }
}
