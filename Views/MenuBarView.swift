import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = PrayerViewModel()
    @State private var showCityPicker = false

    private var theme: SkyTheme { viewModel.skyTheme }

    var body: some View {
        if showCityPicker {
            CityPickerView(
                onCitySelected: {
                    await viewModel.loadPrayerTimes(forceRefresh: true)
                },
                onDismiss: {
                    showCityPicker = false
                }
            )
        } else {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ZStack {
            // Dynamic sky gradient background
            theme.skyGradient
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                // Header
                headerSection
                
                // Thin divider
                theme.dividerColor
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)

                // Prayer Times
                prayerTimesSection
                
                // Thin divider
                theme.dividerColor
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)

                // Fasting Status
                if viewModel.fastingStatus.isFasting {
                    fastingSection
                    
                    theme.dividerColor
                        .frame(height: 0.5)
                        .padding(.horizontal, 12)
                }

                // Actions
                actionsSection
            }
            .padding(.vertical, 10)
        }
        .frame(width: 350)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(theme.skyEmoji)
                        .font(.system(size: 14))
                    Text("AdzanBar")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryTextColor)
                }
                
                Text(viewModel.selectedCity)
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondaryTextColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(viewModel.currentDate)
                    .font(.system(size: 10))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.horizontal, 14)
    }
    
    // MARK: - Prayer Times
    private var prayerTimesSection: some View {
        Group {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(theme.accentColor)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(viewModel.prayerTimes) { prayer in
                        let isNext = prayer.id == viewModel.nextPrayer?.id
                        PrayerRowView(
                            prayer: prayer,
                            isNext: isNext,
                            countdown: isNext ? viewModel.countdown : nil,
                            progress: isNext ? viewModel.nextPrayerProgress : 0.0,
                            theme: theme
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    // MARK: - Fasting Status
    private var fastingSection: some View {
        HStack(spacing: 8) {
            // Fasting indicator dot
            Circle()
                .fill(theme.fastingBadgeColor)
                .frame(width: 6, height: 6)
            
            Text("Sedang Berpuasa")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.fastingBadgeColor)

            if let reason = viewModel.fastingStatus.reason {
                Text("(\(reason))")
                    .font(.system(size: 10))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            if let maghrib = viewModel.prayerTimes.first(where: { $0.name == "Maghrib" }) {
                HStack(spacing: 3) {
                    Image(systemName: "moon.haze.fill")
                        .font(.system(size: 9))
                    Text(PrayerTimeUtils.countdown(to: maghrib.time))
                        .font(.system(size: 10, design: .monospaced))
                }
                .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions
    private var actionsSection: some View {
        HStack(spacing: 8) {
            ThemedButton(label: "Kota", icon: "map", theme: theme) {
                showCityPicker = true
            }

            ThemedButton(label: "Refresh", icon: "arrow.clockwise", theme: theme) {
                Task {
                    await viewModel.loadPrayerTimes(forceRefresh: true)
                }
            }

            Spacer()

            ThemedButton(label: "Quit", icon: "xmark.circle", theme: theme) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Themed Button
struct ThemedButton: View {
    let label: String
    let icon: String
    let theme: SkyTheme
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(theme.primaryTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? theme.buttonHoverBackground : theme.buttonBackground)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
