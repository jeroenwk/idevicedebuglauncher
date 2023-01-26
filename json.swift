import Foundation

func json(_ data: Codable) -> Any? {
    if let d = try? JSONEncoder().encode(data) {
        if let json = try? JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed) {
            return json
        }
    }
    return nil
}

func fromJson(str: String, type: Decodable.Type) -> Any? {
    if let data = str.data(using: .utf8) {
        if let result = try? JSONDecoder().decode(type, from: data) {
            return result
        }
    }
    return nil
}
