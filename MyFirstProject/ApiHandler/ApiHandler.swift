import Foundation
import Combine

final class APIClient {

    static let shared = APIClient()
    private init() {}

    // ------------------------------------------------
    // MARK: - POST (multipart/form-data)
    // ------------------------------------------------
    func postFormData<T: Decodable>(
        urlString: String,
        parameters: [String: String]
    ) -> AnyPublisher<T, Error> {

        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = createFormDataBody(
            parameters: parameters,
            boundary: boundary
        )

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in

                // 🔍 DEBUG (remove in production)
                if let raw = String(data: data, encoding: .utf8) {
                    print("RAW RESPONSE:", raw)
                }

                guard let http = response as? HTTPURLResponse,
                      200..<300 ~= http.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // ------------------------------------------------
    // MARK: - Helper (FormData Body Builder)
    // ------------------------------------------------
    private func createFormDataBody(
        parameters: [String: String],
        boundary: String
    ) -> Data {

        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }
    
    func postMultipartFormData<T: Decodable>(
            urlString: String,
            parameters: [String: String],
            files: [MultipartFile]
        ) -> AnyPublisher<T, Error> {

            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL))
                    .eraseToAnyPublisher()
            }

            let boundary = UUID().uuidString

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )

            request.httpBody = createBody(
                boundary: boundary,
                parameters: parameters,
                files: files
            )

            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse,
                          response.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return output.data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        // MARK: - Multipart Body Builder
        private func createBody(
            boundary: String,
            parameters: [String: String],
            files: [MultipartFile]
        ) -> Data {

            var body = Data()
            let lineBreak = "\r\n"

            // Parameters
            for (key, value) in parameters {
                body.append("--\(boundary)\(lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
                body.append("\(value)\(lineBreak)")
            }

            // Files
            for file in files {
                body.append("--\(boundary)\(lineBreak)")
                body.append(
                    "Content-Disposition: form-data; name=\"\(file.key)\"; filename=\"\(file.fileName)\"\(lineBreak)"
                )
                body.append("Content-Type: \(file.mimeType)\(lineBreak)\(lineBreak)")
                body.append(file.data)
                body.append(lineBreak)
            }

            body.append("--\(boundary)--\(lineBreak)")
            return body
        }
}
    
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}



