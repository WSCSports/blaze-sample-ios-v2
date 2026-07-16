//
//  SampleFollowEntitiesManager.swift
//  blaze-sample-ios-v2
//
//  Created by Igor Yermachonak on 10/07/2026.
//

import Foundation
import BlazeSDK

/// App-side owner of the BlazeSDK Follow Entities feature.
///
/// Bridges the SDK's in-memory follow state (`Blaze.shared.followEntitiesManager`) with local
/// persistence (`SampleFollowEntitiesStorage`) and is the single owner of the SDK's follow
/// delegate — the delegate is one slot, so no other screen should claim it.
///
/// Call `start()` once, after `Blaze.shared.initialize(...)`, to hydrate the SDK from storage
/// and begin persisting the taps the user makes on the in-player follow button.
final class SampleFollowEntitiesManager {

    static let shared = SampleFollowEntitiesManager()

    /// Fired after the followed set changes so callers (e.g. the "Your Picks" tab) can rebuild
    /// their data source. Delivered on the main queue.
    var onFollowChanged: (() -> Void)?

    private let blazeFollowManager = Blaze.shared.followEntitiesManager
    private let storage = SampleFollowEntitiesStorage.shared

    private init() {}

    func start() {
        blazeFollowManager.delegate = self
        let storedEntities = Set(storage.getAllFollowedEntityIds().map { BlazeFollowEntity(id: $0) })
        blazeFollowManager.setFollowedEntities(storedEntities)
    }

    /// Most-recently-followed entity ids first.
    func recentFollowedEntityIds() -> [String] {
        storage.getRecentFollowedEntityIds()
    }

    /// - Parameter completion: Called on the main queue once the write has landed, so
    ///   `recentFollowedEntityIds()` is guaranteed to reflect it.
    private func addFollowedEntity(id: String, completion: @escaping () -> Void) {
        blazeFollowManager.insertFollowedEntities([BlazeFollowEntity(id: id)])
        storage.insertFollowedEntity(id: id) {
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// - Parameter completion: Called on the main queue once the write has landed, so
    ///   `recentFollowedEntityIds()` is guaranteed to reflect it.
    private func removeFollowedEntity(id: String, completion: @escaping () -> Void) {
        blazeFollowManager.removeFollowedEntities([BlazeFollowEntity(id: id)])
        storage.removeFollowedEntity(id: id) {
            DispatchQueue.main.async(execute: completion)
        }
    }
}

// MARK: - BlazeFollowEntitiesDelegate
extension SampleFollowEntitiesManager: BlazeFollowEntitiesDelegate {
    func onFollowEntityClicked(_ params: BlazeFollowEntityClickedParams) {
        // `onFollowChanged` fires only once the storage write completes (via the storage
        // completion, not a parallel `DispatchQueue.main.async`) — otherwise it can run before
        // the write lands, so a rebuild right after a follow reads the list without it.
        let notifyChanged: () -> Void = { [weak self] in self?.onFollowChanged?() }
        if params.newFollowingState {
            addFollowedEntity(id: params.followEntity.id, completion: notifyChanged)
        } else {
            removeFollowedEntity(id: params.followEntity.id, completion: notifyChanged)
        }
    }
}
