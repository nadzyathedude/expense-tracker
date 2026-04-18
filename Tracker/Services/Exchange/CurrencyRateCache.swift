//
//  CurrencyRateCache.swift
//  Tracker
//

import Foundation

nonisolated protocol CurrencyRateCache: Sendable {
    func load(base: String) async -> CurrencyRates?
    func save(_ rates: CurrencyRates) async
}

actor DiskCurrencyRateCache: CurrencyRateCache {
    private let directory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) throws {
        let caches = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.directory = caches.appendingPathComponent("CurrencyRates", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    private func fileURL(for base: String) -> URL {
        directory.appendingPathComponent("\(base.uppercased()).json")
    }

    func load(base: String) async -> CurrencyRates? {
        let url = fileURL(for: base)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(CurrencyRates.self, from: data)
    }

    func save(_ rates: CurrencyRates) async {
        guard let data = try? encoder.encode(rates) else { return }
        let url = fileURL(for: rates.base)
        try? data.write(to: url, options: .atomic)
    }
}
