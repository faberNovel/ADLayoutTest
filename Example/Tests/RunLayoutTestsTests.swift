import XCTest
import ADLayoutTest

struct DummyError: Error {}

class RunLayoutTestsTests: XCTestCase {

    func testDefaultNumberOfTests() {
        var generatedValues: [Int] = []
        let dummyView = UIView()
        runLayoutTests(named: "Test") { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValues.append(value)
            return .success(dummyView)
        }
        XCTAssertEqual(generatedValues.count, 100)
    }

    func testCustomNumberOfTestsIs100() {
        let testsCount = 10
        var generatedValues: [Int] = []
        let dummyView = UIView()
        runLayoutTests(
            named: "Test",
            maxTestsCount: testsCount
        ) { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValues.append(value)
            return .success(dummyView)
        }
        XCTAssertEqual(generatedValues.count, testsCount)
    }

    func testRandomStrategy() {
        var generatedValuesFirstRun: [Int] = []
        var generatedValuesSecondRun: [Int] = []
        let dummyView = UIView()
        runLayoutTests(
            named: "Test",
            randomStrategy: .replay(seed1: 1, seed2: 2, size: 3)
        ) { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValuesFirstRun.append(value)
            return .success(dummyView)
        }
        runLayoutTests(
            named: "Test",
            randomStrategy: .replay(seed1: 3, seed2: 4, size: 5)
        ) { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValuesSecondRun.append(value)
            return .success(dummyView)
        }
        XCTAssertNotEqual(generatedValuesFirstRun, generatedValuesSecondRun)
    }

    func testNoRandomStrategy() {
        var generatedValuesFirstRun: [Int] = []
        var generatedValuesSecondRun: [Int] = []
        let dummyView = UIView()
        runLayoutTests(
            named: "Test",
            randomStrategy: .consistent
        ) { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValuesFirstRun.append(value)
            return .success(dummyView)
        }
        runLayoutTests(
            named: "Test",
            randomStrategy: .consistent
        ) { (value: Int) -> XCTestCase.ViewAssertionResult in
            generatedValuesSecondRun.append(value)
            return .success(dummyView)
        }
        XCTAssertEqual(generatedValuesFirstRun, generatedValuesSecondRun)
    }
}
