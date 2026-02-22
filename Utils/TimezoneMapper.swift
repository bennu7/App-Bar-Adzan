import Foundation

enum PrayerTimeZone: String {
    case wib = "WIB"
    case wita = "WITA"
    case wit = "WIT"
    
    var identifier: String {
        switch self {
        case .wib: return "Asia/Jakarta"
        case .wita: return "Asia/Makassar"
        case .wit: return "Asia/Jayapura"
        }
    }
    
    var timeZone: TimeZone {
        TimeZone(identifier: identifier) ?? TimeZone(identifier: "Asia/Jakarta")!
    }
}

class TimezoneMapper {
    static func getTimeZone(for provinceName: String) -> PrayerTimeZone {
        let normalized = provinceName.uppercased().trimmingCharacters(in: .whitespaces)
        
        // WIB (Sumatera, Jawa, Kalbar, Kalteng)
        let wibProvinces = [
            "ACEH", "SUMATERA UTARA", "SUMATERA BARAT", "RIAU", "JAMBI",
            "SUMATERA SELATAN", "BENGKULU", "LAMPUNG",
            "KEPULAUAN BANGKA BELITUNG", "KEPULAUAN RIAU",
            "DKI JAKARTA", "JAWA BARAT", "JAWA TENGAH", "DI YOGYAKARTA", "JAWA TIMUR", "BANTEN",
            "KALIMANTAN BARAT", "KALIMANTAN TENGAH"
        ]
        
        // WITA (Kalsel, Kaltim, Kaltara, Sulawesi, Bali, Nusa Tenggara)
        let witaProvinces = [
            "BALI", "NUSA TENGGARA BARAT", "NUSA TENGGARA TIMUR",
            "KALIMANTAN SELATAN", "KALIMANTAN TIMUR", "KALIMANTAN UTARA",
            "SULAWESI UTARA", "SULAWESI TENGAH", "SULAWESI SELATAN",
            "SULAWESI TENGGARA", "GORONTALO", "SULAWESI BARAT"
        ]
        
        // WIT (Maluku, Papua)
        let witProvinces = [
            "MALUKU", "MALUKU UTARA",
            "PAPUA", "PAPUA BARAT", "PAPUA SELATAN",
            "PAPUA TENGAH", "PAPUA PEGUNUNGAN", "PAPUA BARAT DAYA"
        ]
        
        if wibProvinces.contains(normalized) { return .wib }
        if witaProvinces.contains(normalized) { return .wita }
        if witProvinces.contains(normalized) { return .wit }
        
        // Default to WIB if unknown
        return .wib
    }
}
