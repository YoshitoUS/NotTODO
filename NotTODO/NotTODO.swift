
import Foundation
import RealmSwift

class NotTODO: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
    
    convenience init(title: String, date: Date) {
        self.init()
        self.title = title
        self.date = date
    }
}
