import SwiftUI

struct PrayerRowView: View {
    let prayer: PrayerTime
    let isNext: Bool
    let countdown: String?
    let progress: Double
    let theme: SkyTheme

    @State private var pulseAnimation: Double = 0.3

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
                // Icon with pill background
                Text(prayer.icon)
                    .font(.system(size: isNext ? 18 : 15))
                    .padding(6)
                    .background(
                        Circle()
                            .fill(theme.iconPillBackground)
                    )
                    .frame(width: 36, height: 36)

                // Name
                Text(prayer.name)
                    .font(.system(size: isNext ? 13 : 12, weight: isNext ? .semibold : .regular))
                    .foregroundColor(isNext ? theme.accentColor : theme.primaryTextColor)
                    .frame(width: 65, alignment: .leading)

                // Countdown (only for next prayer, larger & prominent)
                if isNext, let countdown = countdown {
                    Text(countdown)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.accentColor)
                }

                Spacer()

                // Time with badge capsule
                Text(formatTime(prayer.time))
                    .font(.system(size: isNext ? 12 : 11, weight: isNext ? .medium : .regular, design: .monospaced))
                    .foregroundColor(theme.timeBadgeTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isNext ? theme.accentColor : theme.timeBadgeBackground)
                    )

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

                        // Fill with gradient
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
        // Glassmorphism card background
        .background(
            Group {
                if isNext {
                    // Next prayer: enhanced glass with gradient border
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.nextPrayerCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            theme.nextPrayerBorder.opacity(pulseAnimation),
                                            theme.nextPrayerBorder.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: theme.nextPrayerShadowColor, radius: 10, x: 0, y: 4)
                } else {
                    // Normal prayer: subtle glass
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.cardBorder, lineWidth: 0.5)
                        )
                }
            }
        )
        // Scale effect for next prayer
        .scaleEffect(isNext ? 1.02 : 1.0)
        // Pulse animation for next prayer
        .onAppear {
            if isNext {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    pulseAnimation = 0.8
                }
            }
        }
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
