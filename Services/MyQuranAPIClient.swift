import Foundation

class MyQuranAPIClient {
    static let shared = MyQuranAPIClient()
    private let baseURL = "https://api.myquran.com/v3/sholat"
    
    // MARK: - Fetch All Cities
    func fetchAllCities() async throws -> [City] {
        let url = URL(string: "\(baseURL)/kota/semua")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CityListResponse.self, from: data)
        return response.data
    }
    
    // MARK: - Search Cities
    func searchCities(keyword: String) async throws -> [City] {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? keyword
        let url = URL(string: "\(baseURL)/kota/cari/\(encodedKeyword)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CitySearchResponse.self, from: data)
        return response.data.hasil
    }
    
    // MARK: - Fetch Today's Schedule
    func fetchTodaySchedule(cityId: String) async throws -> PrayerScheduleData {
        let url = URL(string: "\(baseURL)/jadwal/\(cityId)/today")!
        print("🌐 Fetching URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Print HTTP response
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Status Code: \(httpResponse.statusCode)")
        }
        
        // Print raw JSON
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw JSON: \(jsonString)")
        }
        
        let decoded = try JSONDecoder().decode(PrayerScheduleResponse.self, from: data)
        print("✅ Decoded successfully")
        return decoded.data
    }
//    func fetchTodaySchedule(cityId: String) async throws -> PrayerScheduleData {
//        let url = URL(string: "\(baseURL)/jadwal/\(cityId)/today")!
//        let (data, _) = try await URLSession.shared.data(from: url)
//        
//        
//        let response = try JSONDecoder().decode(PrayerScheduleResponse.self, from: data)
//        return response.data
//    }
}
