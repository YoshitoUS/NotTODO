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
    private static var realm: Realm {
        var config = Realm.Configuration()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.NotTODO.group")!
        config.fileURL = url.appendingPathComponent("db.realm")
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    static func all() -> Results<NotTODO> {
        realm.objects(self)
    }
    
    static func create(with notTODO: NotTODO) {
        try! realm.write {
            realm.create(NotTODO.self, value: notTODO, update: .all)
        }
    }
}
