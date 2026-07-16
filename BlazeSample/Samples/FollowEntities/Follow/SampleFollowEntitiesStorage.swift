//
//  SampleFollowEntitiesStorage.swift
//  blaze-sample-ios-v2
//
//  Created by Igor Yermachonak on 10/07/2026.
//

import Foundation

/// Local persistence for the entities the user follows.
///
/// A production app would sync follow state with its backend. This sample keeps it deliberately
/// simple with `UserDefaults` so the personalization flow is fully self-contained and reviewable.
///
/// Order is significant: ids are stored oldest-first / most-recently-followed-last so the
/// "Your Picks" tab can prioritize the freshest follows via `getRecentFollowedEntityIds(limit:)`.
final class SampleFollowEntitiesStorage {

    static let shared = SampleFollowEntitiesStorage()

    private let userDefaults = UserDefaults.standard
    private let followedEntitiesKey = "BlazeSample.FollowedEntities"
    private let queue = DispatchQueue(label: "com.blaze.sample.followEntities.storage", attributes: .concurrent)

    private init() {}

    /// - Parameter completion: Called once the write has landed, still on the storage queue —
    ///   hop to another queue yourself if you touch UI. Lets callers avoid reading a stale
    ///   list right after a write (the write is otherwise fire-and-forget).
    func insertFollowedEntity(id: String, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            var current = self.loadOrderedNoLock()
            current.removeAll { $0 == id }
            current.append(id)
            self.saveOrderedNoLock(current)
            completion?()
        }
    }

    /// - Parameter completion: Called once the write has landed, still on the storage queue —
    ///   hop to another queue yourself if you touch UI. Lets callers avoid reading a stale
    ///   list right after a write (the write is otherwise fire-and-forget).
    func removeFollowedEntity(id: String, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            var current = self.loadOrderedNoLock()
            current.removeAll { $0 == id }
            self.saveOrderedNoLock(current)
            completion?()
        }
    }

    func getAllFollowedEntityIds() -> Set<String> {
        queue.sync { Set(loadOrderedNoLock()) }
    }

    /// Most-recently-followed ids first.
    func getRecentFollowedEntityIds() -> [String] {
        queue.sync { Array(loadOrderedNoLock().reversed()) }
    }

    private func loadOrderedNoLock() -> [String] {
        let stored = userDefaults.stringArray(forKey: followedEntitiesKey) ?? []
        var seen = Set<String>()
        return stored.filter { seen.insert($0).inserted }
    }

    private func saveOrderedNoLock(_ ids: [String]) {
        userDefaults.set(ids, forKey: followedEntitiesKey)
    }
}
