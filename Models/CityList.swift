import Foundation

// MARK: - City Models
struct City: Identifiable, Codable {
    let id: String
    let lokasi: String
    
    var displayName: String {
        lokasi
    }
}

struct CityListResponse: Codable {
    let status: Bool
    let data: [City]
}

struct CitySearchResponse: Codable {
    let status: Bool
    let data: CitySearchData
}

struct CitySearchData: Codable {
    let hasil: [City]
}
