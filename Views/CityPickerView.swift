import SwiftUI

struct CityPickerView: View {
    @State private var cities: [City] = []
    @State private var searchText = ""
    @State private var isLoadingCities = false
    @State private var isSelecting = false
    @State private var selectedCityId: String?
    
    var onCitySelected: (() async -> Void)?
    var onDismiss: (() -> Void)?
    
    private let service = PrayerService.shared
    private let theme = SkyTheme(isGlassMode: UserPreferences.shared.isGlassMode)
    
    var filteredCities: [City] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter { $0.lokasi.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            // Sky gradient background
            theme.skyGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 12))
                            .foregroundColor(theme.accentColor)
                        Text("Pilih Kota")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.primaryTextColor)
                    }
                    Spacer()
                    ThemedButton(label: "Kembali", icon: "chevron.left", theme: theme) {
                        onDismiss?()
                    }
                    .disabled(isSelecting)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryTextColor)
                    TextField("Cari kota...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundColor(theme.primaryTextColor)
                        .disabled(isSelecting)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.cardBorder, lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 14)
                
                // Divider
                theme.dividerColor
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                
                // City List
                if isLoadingCities {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(theme.accentColor)
                        Text("Memuat daftar kota...")
                            .font(.system(size: 11))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isSelecting {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(theme.accentColor)
                        Text("Memuat jadwal sholat...")
                            .font(.system(size: 11))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedCityId) {
                        ForEach(filteredCities) { city in
                            Text(city.lokasi)
                                .font(.system(size: 12))
                                .tag(city.id)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onChange(of: selectedCityId) { newValue in
                        guard let cityId = newValue,
                              let city = cities.first(where: { $0.id == cityId }) else { return }
                        
                        // Reset selection immediately to allow re-selecting same city
                        selectedCityId = nil
                        
                        print("City selected: \(city.lokasi)")
                        Task {
                            await selectCity(city)
                        }
                    }
                }
            }
        }
        .frame(width: 350)
        .task {
            await loadCities()
        }
    }
    
    private func loadCities() async {
        isLoadingCities = true
        do {
            cities = try await service.fetchAllCities()
        } catch {
            print("Failed to load cities: \(error)")
        }
        isLoadingCities = false
    }
    
    private func selectCity(_ city: City) async {
        isSelecting = true
        
        // Save city preference
        UserPreferences.shared.setCity(id: city.id, name: city.lokasi)
        
        // Fetch prayer data
        await onCitySelected?()
        
        isSelecting = false
        
        // Go back to main view after data loaded
        onDismiss?()
    }
}
