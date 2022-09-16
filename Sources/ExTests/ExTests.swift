import XCTest

public extension XCTestExpectation {

    func strict() -> Self {
        assertForOverFulfill = true
        return self
    }

    func soft() -> Self {
        assertForOverFulfill = false
        return self
    }

    func expect(_ count: Int) -> Self {
        expectedFulfillmentCount = count
        return self
    }

    func once() -> Self {
        expect(1)
    }

    func onceStrict() -> Self {
        expect(1).strict()
    }

    func inverted() -> Self {
        isInverted = true
        return self
    }

    func regular() -> Self {
        isInverted = false
        return self
    }

}
