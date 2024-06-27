import Foundation
import RealmSwift
import UIKit

class NotTODO: Object, Identifiable {
    @objc dynamic var id: ObjectId = ObjectId.generate()
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var hasNotification: Bool = false
    @objc dynamic var repeatUntil: Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, date: Date, repeatUntil: Date) {
        self.init()
        self.title = title
        self.date = date
        self.repeatUntil = repeatUntil
    }
}

extension NotTODO {
    static var realm: Realm {
        var config = Realm.Configuration()
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Usui.Crayon.NotTODO") {
            config.fileURL = appGroupURL.appendingPathComponent("db.realm")
        }
        config.schemaVersion = 3
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 3 {
                migration.enumerateObjects(ofType: NotTODO.className()) { oldObject, newObject in
                    newObject!["repeatUntil"] = Date()
                }
            }
        }
        return try! Realm(configuration: config)
    }

    static func all() -> Results<NotTODO> {
        return realm.objects(NotTODO.self)
    }

    static func create(with notTODO: NotTODO) {
        try! realm.write {
            realm.add(notTODO, update: .all)
        }
    }

    static func update(_ notTODO: NotTODO) {
        try! realm.write {
            realm.add(notTODO, update: .modified)
        }
    }

    static func delete(_ notTODO: NotTODO) {
        try! realm.write {
            realm.delete(notTODO)
        }
    }
}
