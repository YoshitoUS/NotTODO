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
        let notTODOs = Array(NotTODO.all())
        
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
        VStack(alignment: .leading) {
            Text("NotTODO List")
                .font(.headline)

            ForEach(entry.notTODOs.prefix(5), id: \.id) { notTODO in
                HStack {
                    Image(systemName: notTODO.isChecked ? "checkmark.circle.fill" : "circle")
                    Text(notTODO.title)
                        .font(.subheadline)
                }
            }
        }
        .padding()
    }
}

struct NotTODOWidget: Widget {
    let kind: String = "NotTODOWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NotTODOWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("NotTODO Widget")
        .description("This is a widget to display your NotTODO list.")
    }
}

#Preview(as: .systemSmall) {
    NotTODOWidget()
} timeline: {
    SimpleEntry(date: .now, notTODOs: [
        NotTODO(title: "Sample Task 1", date: Date()),
        NotTODO(title: "Sample Task 2", date: Date())
    ])
}
