import WidgetKit
import SwiftUI
import RealmSwift

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), notTODOs: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let notTODOs = Array(NotTODO.all())
        let entry = SimpleEntry(date: Date(), notTODOs: notTODOs)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        // 現在の日付から始まるタイムラインを生成
        let currentDate = Date()
        let notTODOs = Array(NotTODO.all().prefix(4)) // リストの個数を4つに制限
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, notTODOs: notTODOs)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let notTODOs: [NotTODO]
}

struct NotTODOWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("NotTODO List")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                ForEach(entry.notTODOs.prefix(4), id: \.id) { notTODO in
                    HStack {
                        Image(systemName: notTODO.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.white)
                        Text(notTODO.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 2)
                }

                // 追加する改行の数を計算
                let additionalLines = max(0, 4 - entry.notTODOs.count)
                ForEach(0..<additionalLines, id: \.self) { _ in
                    Text("") // 空のTextビューを使用して改行を追加
                }
                
                Spacer()
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            Color(red: 115/255, green: 139/255, blue: 147/255)
        }
    }
}


struct NotTODOLockScreenEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0.1) {
                Text("NotTODO List")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.top, 12)
                
                ForEach(entry.notTODOs.prefix(3), id: \.id) { notTODO in // リストの個数を3つに制限
                    HStack {
                        Image(systemName: notTODO.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.white)
                            .frame(width: 1, height: 1)
                        Text(notTODO.title)
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 2)
                }
                Spacer()
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            Color(red: 115/255, green: 139/255, blue: 147/255)
        }
    }
}


struct NotTODOLockScreenWidget: Widget {
    let kind: String = "NotTODOLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NotTODOLockScreenEntryView(entry: entry)
                .widgetURL(URL(string: "yourappscheme://"))
        }
        .configurationDisplayName("NotTODO Lock Screen Widget")
        .description("Displays your NotTODO list on the lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct NotTODOWidget: Widget {
    let kind: String = "NotTODOWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NotTODOWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NotTODO Widget")
        .description("This is a widget to display your NotTODO list.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NotTODOWidget_Previews: PreviewProvider {
    static var previews: some View {
        NotTODOWidgetEntryView(entry: SimpleEntry(date: Date(), notTODOs: [
            NotTODO(title: "Sample Task 1", date: Date(), repeatUntil: Date()),
            NotTODO(title: "Sample Task 2", date: Date(), repeatUntil: Date())
        ]))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
