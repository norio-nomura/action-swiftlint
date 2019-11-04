import XCTest

import errorsTests

var tests = [XCTestCaseEntry]()
tests += errorsTests.allTests()
XCTMain(tests)
