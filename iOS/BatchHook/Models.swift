import Foundation

struct RugEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var pattern: String
    var wool: String
    var backing: String
    var notes: String
    var dateCreated: Date = Date()
}
