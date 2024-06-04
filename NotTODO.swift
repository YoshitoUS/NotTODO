import Foundation
import RealmSwift

class NotTODO: Object, Identifiable {
    @objc dynamic var id: ObjectId = ObjectId.generate()
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, date: Date) {
        self.init()
        self.title = title
        self.date = date
    }
}

extension NotTODO {
     static var realm: Realm {
        var config = Realm.Configuration()
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.NotTODO.group") {
            config.fileURL = appGroupURL.appendingPathComponent("db.realm")
        }
        config.schemaVersion = 1 // 必要に応じてスキーマバージョンを更新
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // ここでマイグレーション処理を追加
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
