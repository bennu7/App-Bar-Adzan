import SwiftUI

struct PrayerRowView: View {
    let prayer: PrayerTime
    let isNext: Bool
    let countdown: String?
    let progress: Double
    let theme: SkyTheme
    
    init(prayer: PrayerTime, isNext: Bool, countdown: String?, progress: Double = 0.0, theme: SkyTheme = SkyTheme()) {
        self.prayer = prayer
        self.isNext = isNext
        self.countdown = countdown
        self.progress = progress
        self.theme = theme
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row content
            HStack(spacing: 10) {
                // Icon
                Text(prayer.icon)
                    .font(.system(size: isNext ? 18 : 15))
                    .frame(width: 24)
                
                // Name
                Text(prayer.name)
                    .font(.system(size: isNext ? 13 : 12, weight: isNext ? .semibold : .regular))
                    .foregroundColor(isNext ? theme.accentColor : theme.primaryTextColor)
                    .frame(width: 65, alignment: .leading)
                
                // Countdown (only for next prayer, larger & prominent)
                if isNext, let countdown = countdown {
                    Text(countdown)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.accentColor)
                }
                
                Spacer()
                
                // Time
                Text(formatTime(prayer.time))
                    .font(.system(size: isNext ? 13 : 12, weight: isNext ? .medium : .regular, design: .monospaced))
                    .foregroundColor(isNext ? theme.primaryTextColor : theme.secondaryTextColor)
                
                // Timezone Label
                Text(prayer.timeZone)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(theme.secondaryTextColor.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.primaryTextColor.opacity(0.06))
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, isNext ? 10 : 7)
            
            // Progress bar (only for next prayer)
            if isNext {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(theme.progressTrackColor)
                            .frame(height: 3)
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(
                                LinearGradient(
                                    colors: [theme.progressFillColor.opacity(0.7), theme.progressFillColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 3)
                            .animation(.linear(duration: 1.0), value: progress)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isNext ? theme.nextPrayerCardBackground : theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isNext ? theme.nextPrayerBorder : theme.cardBorder, lineWidth: isNext ? 1.0 : 0.5)
                )
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeZone = TimeZone(identifier: prayer.timeZoneIdentifier) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: date)
    }
}
