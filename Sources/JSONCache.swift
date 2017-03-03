import Foundation

// JSON cache

public protocol JSONOriginatedObject {
    typealias JSONSource = [String:AnyObject]
    var json: JSONSource { get }
    init?(json: JSONSource)
}

public class JSONCache {
    public static let appDirCache = JSONCache()
    public let fileManager  = FileManager()
    let cachePath: String
    
    /// Print debug message if true
    var verbose: Bool = false
    
    public enum CacheError:Error {
        case cacheCreationError
        case cacheNotWrittable
    }
    
    /**
     Storage path should be readable.
     If nil, will try to create a cache directory in app directory
     */
    public init(storagePath: String? = nil) {
        if let storagePath = storagePath {
            self.cachePath = storagePath
        } else {
            self.cachePath = fileManager.currentDirectoryPath +  "/cache"
        }
    }
    
    /// Creates cache dir if needed
    func prepareCacheDir() throws{
        var isDir : ObjCBool = false
        if !fileManager.fileExists(atPath: cachePath, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: URL.init(fileURLWithPath: cachePath), withIntermediateDirectories: false, attributes: [:])
            } catch {
                throw CacheError.cacheCreationError
            }
        }
    }
    
    private func sanatize(id: String) -> String {
        return id.replacingOccurrences(of: ".", with: "_")
    }
    
    public func cachePath(for id: String) -> String {
        let safeId = self.sanatize(id: id)
        let targetPath = self.cachePath + "/" + safeId
        return targetPath
    }
    
    /**
     Save JSON-like object to cache file with given id
     */
    public func save(_ object: JSONOriginatedObject, as id: String) throws {
        try prepareCacheDir()
        let jsonData = try JSONSerialization.data(withJSONObject: object.json as Any, options: [])
        do {
            try jsonData.write(to: URL(fileURLWithPath: cachePath(for: id) ))
            if verbose {
                print("[Debug JSON cache] Cache created for id \(id)")
            }
        } catch {
            throw CacheError.cacheNotWrittable
        }
    }
    
    public func load<T:JSONOriginatedObject>(id: String, validityInterval: TimeInterval? = nil) -> T? {
        if let validityInterval = validityInterval, !isCacheValid(id: id, validityInterval: validityInterval) {
            return nil
        }
        let path = cachePath(for: id)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let json  = json as? JSONOriginatedObject.JSONSource {
                return T(json: json)
            } else {
                return nil
            }
        }
        return nil
    }
    
    public func isCacheValid(id: String, validityInterval: TimeInterval) -> Bool {
        let attributes = try? fileManager.attributesOfItem(atPath: cachePath(for: id))
        if let attributes = attributes, let creationDate = attributes[.modificationDate] as? Date {
            let age = Date().timeIntervalSince(creationDate)
            if age < validityInterval {
                if verbose {
                    print("[Debug JSON cache] Valid cache for id: \(id) with age: \(age)s")
                }
                return true
            } else if verbose {
                print("[Debug JSON cache] Invalid age \(age)s for id: \(id) ")
            }
        }
        return false
    }
    
}
