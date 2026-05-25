import Foundation

enum ExchangeRateAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The exchange-rate URL is invalid."
        case .invalidResponse:
            return "The exchange-rate server returned an invalid response."
        case .requestFailed(let message):
            return message
        }
    }
}

struct ExchangeRateAPIService {
    private let baseURL = URL(string: "https://api.frankfurter.dev/v2")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchRate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRateDTO {
        let url = baseURL.appending(path: "rate/\(baseCode)/\(quoteCode)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ExchangeRateAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try? JSONDecoder().decode(ServerErrorDTO.self, from: data)
            throw ExchangeRateAPIError.requestFailed(
                serverError?.message ?? "Unable to fetch the latest exchange rate."
            )
        }

        return try JSONDecoder().decode(ExchangeRateDTO.self, from: data)
    }
}

private struct ServerErrorDTO: Decodable {
    let message: String
}
