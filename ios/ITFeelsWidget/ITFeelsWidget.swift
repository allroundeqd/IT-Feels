import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "IT-Feels", artist: "Play some music!")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntry() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.itfeels.music")
        let title = userDefaults?.string(forKey: "widget_title") ?? "No Music Playing"
        let artist = userDefaults?.string(forKey: "widget_artist") ?? "Open IT-Feels to play"
        
        return SimpleEntry(date: Date(), title: title, artist: artist)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let artist: String
}

struct ITFeelsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("IT-Feels Now Playing")
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(entry.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
            
            Text(entry.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
    }
}

@main
struct ITFeelsWidget: Widget {
    let kind: String = "ITFeelsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ITFeelsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ITFeelsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("IT-Feels Now Playing")
        .description("Shows the currently playing song.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
