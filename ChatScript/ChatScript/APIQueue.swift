// APIQueue.swift

import Foundation

class APIQueue: ObservableObject {
    @Published private(set) var totalRequests: Int = 0
    @Published private(set) var completedRequests: Int = 0

    private let queue = DispatchQueue(label: "com.chatscripts.apiqueue", attributes: .concurrent)
    private var pendingRequests: [(String, (Result<String, Error>) -> Void)] = []
    private var isProcessing = false
    private let maxBatchSize = 5
    private let cacheManager = CacheManager.shared

    func enqueue(request: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            self?.pendingRequests.append((request, completion))
            self?.totalRequests += 1
            self?.processQueueIfNeeded()
        }
    }

    func enqueue(request: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            enqueue(request: request) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func processQueueIfNeeded() {
        guard !isProcessing else { return }
        isProcessing = true
        processBatch()
    }

    private func processBatch() {
        queue.async { [weak self] in
            guard let self = self else { return }

            let batch = Array(self.pendingRequests.prefix(self.maxBatchSize))
            guard !batch.isEmpty else {
                self.isProcessing = false
                return
            }

            self.pendingRequests.removeFirst(batch.count)

            let group = DispatchGroup()

            for (request, completion) in batch {
                group.enter()

                if let cachedResult = self.cacheManager.getFromCache(for: request) {
                    completion(.success(cachedResult))
                    self.incrementCompletedRequests()
                    group.leave()
                } else {
                    self.sendAPIRequest(request) { result in
                        switch result {
                        case .success(let response):
                            self.cacheManager.addToCache(request: request, response: response)
                        case .failure:
                            break
                        }
                        completion(result)
                        self.incrementCompletedRequests()
                        group.leave()
                    }
                }
            }

            group.notify(queue: self.queue) {
                self.processBatch()
            }
        }
    }

    private func incrementCompletedRequests() {
        DispatchQueue.main.async {
            self.completedRequests += 1
            if self.completedRequests == self.totalRequests {
                self.resetProgress()
            }
        }
    }

    private func resetProgress() {
        self.totalRequests = 0
        self.completedRequests = 0
    }

    private func sendAPIRequest(_ prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Determine the AI provider and API key
        let selectedProvider: AIProvider = {
            if let providerRawValue = UserDefaults.standard.string(forKey: "SelectedAIProvider"),
               let provider = AIProvider(rawValue: providerRawValue) {
                return provider
            } else {
                return .anthropicClaudeHaiku // Default provider
            }
        }()
        
        let aiService = AIService(provider: selectedProvider)
        
        aiService.generateScript(from: prompt) { result in
            switch result {
            case .success(let script):
                completion(.success(script))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
