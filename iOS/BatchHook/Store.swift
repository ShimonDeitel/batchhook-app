import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [RugEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("batchhook_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        RugEntry(name: "Folk Art Rooster", pattern: "Primitive rooster", wool: "Reds, mustard, cream", backing: "Linen 24x36in", notes: "Half done"),
        RugEntry(name: "Geometric Runner", pattern: "Diamond geometric", wool: "Navy, gray wool strips", backing: "Monk's cloth 60x18in", notes: "Hallway rug"),
        RugEntry(name: "Floral Chair Pad", pattern: "Rose medallion", wool: "Pinks, greens", backing: "Burlap 14x14in", notes: "Finished, bound edges")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(name: String, pattern: String, wool: String, backing: String, notes: String) {
        guard canAddMore else { return }
        let entry = RugEntry(name: name, pattern: pattern, wool: wool, backing: backing, notes: notes)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: RugEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: RugEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([RugEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
