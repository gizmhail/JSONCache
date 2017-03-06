import XCTest
@testable import JSONCache

struct Sample:JSONOriginatedObject{
    var json:[String:Any]
    init?(json:[String:Any]){
        self.json = json
    }
}

class JSONCacheTests: XCTestCase {

    func testList(){
        do {
            if let sample = Sample(json: ["test":1]) {
                try JSONCache.appDirCache.save(sample, as: "test")
                var files = try JSONCache.appDirCache.listCachedFiles()
                print("\(files)")
                try JSONCache.appDirCache.delete(id: "test")
                files = try JSONCache.appDirCache.listCachedFiles()
                print("\(files)")
            }
        } catch {
            print(error)
        }
    }

    static var allTests : [(String, (JSONCacheTests) -> () throws -> Void)] {
        return [
            ("testList", testList),
        ]
    }
}
