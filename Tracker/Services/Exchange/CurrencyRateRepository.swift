//
//  CurrencyRateRepository.swift
//  Tracker
//

import Foundation

nonisolated protocol CurrencyRateRepository: Sendable {
    func rates(base: String) async throws -> CurrencyRates
}

nonisolated final class DefaultCurrencyRateRepository: CurrencyRateRepository {
    private let client: APIClient
    private let cache: CurrencyRateCache
    private let ttl: TimeInterval
    private let now: @Sendable () -> Date

    private static let defaultEndpoint = URL(string: "https://api.exchangerate.host")!

    init(
        client: APIClient,
        cache: CurrencyRateCache,
        ttl: TimeInterval = 60 * 60 * 12,
        now: @Sendable @escaping () -> Date = { Date() }
    ) {
        self.client = client
        self.cache = cache
        self.ttl = ttl
        self.now = now
    }

    func rates(base: String) async throws -> CurrencyRates {
        let code = base.uppercased()

        if let stored = await cache.load(base: code), isFresh(stored) {
            return stored
        }

        do {
            let fresh = try await fetchFromNetwork(base: code)
            await cache.save(fresh)
            return fresh
        } catch {
            if let fallback = await cache.load(base: code) {
                return fallback
            }
            throw error
        }
    }

    private func isFresh(_ rates: CurrencyRates) -> Bool {
        now().timeIntervalSince(rates.fetchedAt) < ttl
    }

    private func fetchFromNetwork(base: String) async throws -> CurrencyRates {
        let endpoint = Endpoint(
            baseURL: Self.defaultEndpoint,
            path: "latest",
            queryItems: [URLQueryItem(name: "base", value: base)]
        )
        let response: ExchangeRatesResponse = try await client.request(endpoint)
        return CurrencyRates(base: response.base, fetchedAt: now(), rates: response.rates)
    }
}
