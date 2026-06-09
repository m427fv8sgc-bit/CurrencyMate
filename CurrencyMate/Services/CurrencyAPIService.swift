import Foundation
// Review: make option to have multiple API option to select for the service.
// Interceptor :
// Custom buttonStyles.

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
    private static let defaultBaseURL = URL(string: "https://api.frankfurter.dev/v2")!

    private let baseURL: URL
    private let urlSession: URLSessionDataProviding

    init(
        baseURL: URL = CurrencyAPIService.defaultBaseURL,
        urlSession: URLSessionDataProviding = URLSession.shared
    ) {
        self.baseURL = baseURL
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

        let url = try rateURL(from: baseCode, to: quoteCode)

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

    private func rateURL(from baseCode: String, to quoteCode: String) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw CurrencyAPIError.invalidURL
        }

        let existingPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = [existingPath, "rate", baseCode, quoteCode]
            .filter { !$0.isEmpty }
            .joined(separator: "/")

        components.path = "/" + path

        guard let url = components.url else {
            throw CurrencyAPIError.invalidURL
        }

        return url
    }
}

private struct ExchangeRateResponse: Decodable {
    let date: String
    let base: String
    let quote: String
    let rate: Double
}
