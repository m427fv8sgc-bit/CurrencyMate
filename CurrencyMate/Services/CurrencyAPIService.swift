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
    private let decoder: JSONDecoder

    init(
        baseURL: URL = CurrencyAPIService.defaultBaseURL,
        urlSession: URLSessionDataProviding = URLSession.shared,
        decoder: JSONDecoder = CurrencyAPIService.makeDecoder()
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func fetchRate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate {
        if baseCode == quoteCode {
            return ExchangeRate(
                baseCode: baseCode,
                quoteCode: quoteCode,
                rate: 1,
                date: Date()
            )
        }

        let url = try rateURL(from: baseCode, to: quoteCode)

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CurrencyAPIError.invalidResponse
        }

        return try decoder.decode(ExchangeRate.self, from: data)
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

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(makeAPIDateFormatter())
        return decoder
    }

    private static func makeAPIDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
