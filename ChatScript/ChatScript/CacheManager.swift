import Foundation

class CacheManager {
    static let shared = CacheManager()

    private init() {}

    private var cache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "com.chatscripts.cachemanager", attributes: .concurrent)

    func getFromCache(for request: String) -> String? {
        var result: String?
        cacheQueue.sync {
            result = cache[request]
        }
        return result
    }

    func addToCache(request: String, response: String) {
        cacheQueue.async(flags: .barrier) {
            self.cache[request] = response
        }
    }

    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
