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
