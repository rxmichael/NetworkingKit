import XCTest
@testable import NetworkingKit

final class NetworkingKitTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        let expected = TestEndpoint.episode.asURLRequest()?.url
        print(expected)

    }
}


enum TestEndpoint: Endpoint {
    case character(page: Int)
    case episode

    var baseURL: URL {
        URL(string: "https://rickandmortyapi.com/api")!
    }

    var path: String {
        return switch self {
        case .character:
        "/character"
        case .episode:
        "/episode"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: RequestParameters? {
        return switch self {
        case .character(let page):
                .query(["page": page])
        default:
            nil
        }
    }
}

