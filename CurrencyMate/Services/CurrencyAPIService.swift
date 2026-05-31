import Foundation

protocol CurrencyRateFetching {
    func fetchRate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate
}

protocol URLSessionDataProviding {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionDataProviding {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }
}

enum CurrencyAPIError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not create the exchange-rate URL."
        case .invalidResponse:
            return "Could not load the latest exchange rate."
        }
    }
}

struct CurrencyAPIService: CurrencyRateFetching {
    private let urlSession: URLSessionDataProviding

    init(urlSession: URLSessionDataProviding = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchRate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate {
        if baseCode == quoteCode {
            return ExchangeRate(
                baseCode: baseCode,
                quoteCode: quoteCode,
                rate: 1,
                date: "Today"
            )
        }

        guard let url = URL(string: "https://api.frankfurter.dev/v2/rate/\(baseCode)/\(quoteCode)") else {
            throw CurrencyAPIError.invalidURL
        }

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CurrencyAPIError.invalidResponse
        }

        let apiResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        return ExchangeRate(
            baseCode: apiResponse.base,
            quoteCode: apiResponse.quote,
            rate: apiResponse.rate,
            date: apiResponse.date
        )
    }
}

private struct ExchangeRateResponse: Decodable {
    let date: String
    let base: String
    let quote: String
    let rate: Double
}
