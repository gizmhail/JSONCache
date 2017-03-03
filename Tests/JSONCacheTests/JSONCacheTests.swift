import XCTest
@testable import JSONCache

class JSONCacheTests: XCTestCase {
    func testExample() {
        XCTAssertNotNil(JSONCache.appDirCache)        
    }


    static var allTests : [(String, (JSONCacheTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
