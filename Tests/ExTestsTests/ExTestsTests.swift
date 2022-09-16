import XCTest
@testable import ExTests

final class ExTestsTests: XCTestCase {


    func test_strict() {

        // Arrange
        var sut = expectation(description: "sut")
        sut.assertForOverFulfill = false

        defer {
            DispatchQueue.main.async {
                sut.fulfill()
            }
            waitForExpectations(timeout: 0.001)
        }

        // Act
        sut = sut.strict()

        // Assert
        XCTAssertTrue( sut.assertForOverFulfill )


    }

}
