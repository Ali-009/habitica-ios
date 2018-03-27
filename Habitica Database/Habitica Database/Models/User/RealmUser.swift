//
//  RealmUser.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class RealmUser: Object, UserProtocol {

    
    @objc dynamic var id: String?
    @objc dynamic var balance: Float = 0
    var tasksOrder: [String: [String]] = [:]
    var stats: StatsProtocol? {
        get {
            return realmStats
        }
        set {
            if let newStats = newValue as? RealmStats {
                realmStats = newStats
                return
            }
            if let stats = newValue {
                realmStats = RealmStats(id: id, stats: stats)
            }
        }
    }
    @objc dynamic var realmStats: RealmStats?
    
    var flags: FlagsProtocol? {
        get {
            return realmFlags
        }
        set {
            if let newFlags = newValue as? RealmFlags {
                realmFlags = newFlags
                return
            }
            if let newFlags = newValue {
                realmFlags = RealmFlags(id: id, flags: newFlags)
            }
        }
    }
    @objc dynamic var realmFlags: RealmFlags?
    
    var preferences: PreferencesProtocol? {
        get {
            return realmPreferences
        }
        set {
            if let newPreferences = newValue as? RealmPreferences {
                realmPreferences = newPreferences
                return
            }
            if let newPreferences = newValue {
                realmPreferences = RealmPreferences(id: id, preferences: newPreferences)
            }
        }
    }
    @objc dynamic var realmPreferences: RealmPreferences?
    
    var profile: ProfileProtocol? {
        get {
            return realmProfile
        }
        set {
            if let newProfile = newValue as? RealmProfile {
                realmProfile = newProfile
                return
            }
            if let profile = newValue {
                realmProfile = RealmProfile(id: id, profile: profile)
            }
        }
    }
    @objc dynamic var realmProfile: RealmProfile?
    
    var contributor: ContributorProtocol? {
        get {
            return realmContributor
        }
        set {
            if let newContributor = newValue as? RealmContributor {
                realmContributor = newContributor
                return
            }
            if let newContributor = newValue {
                realmContributor = RealmContributor(id: id, contributor: newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    var items: UserItemsProtocol? {
        get {
            return realmItems
        }
        set {
            if let newItems = newValue as? RealmUserItems {
                realmItems = newItems
                return
            }
            if let newItems = newValue {
                realmItems = RealmUserItems(id: id, userItems: newItems)
            }
        }
    }
    @objc dynamic var realmItems: RealmUserItems?
    var tags: [TagProtocol] {
        get {
            return realmTags.map({ (tag) -> TagProtocol in
                return tag
            })
        }
        set {
            realmTags.removeAll()
            newValue.forEach { (tag) in
                if let realmTag = tag as? RealmTag {
                    realmTags.append(realmTag)
                } else {
                    realmTags.append(RealmTag(tag))
                }
            }
        }
    }
    var realmTags = List<RealmTag>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["flags", "preferences", "stats", "profile", "contributor", "tasksOrder", "items", "tags"]
    }
    
    convenience init(_ user: UserProtocol) {
        self.init()
        id = user.id
        stats = user.stats
        flags = user.flags
        preferences = user.preferences
        profile = user.profile
        contributor = user.contributor
        balance = user.balance
        items = user.items
        tags = user.tags
    }
}