//
//  VibeShareWidgetBundle.swift
//  VibeShareWidget
//
//  Created by Joshua Reinoso on 04/05/2026.
//

import WidgetKit
import SwiftUI

// Widget simple para iOS 17.0+
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageUrl: "", caption: "VibeShare")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadWidgetData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = loadWidgetData()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func loadWidgetData() -> SimpleEntry {
        guard let defaults = UserDefaults(suiteName: "group.com.tuapp.vibeshare"),
              let jsonString = defaults.string(forKey: "latest_images"),
              let data = jsonString.data(using: .utf8),
              let images = try? JSONDecoder().decode([WidgetImage].self, from: data),
              let first = images.first else {
            return SimpleEntry(date: Date(), imageUrl: "", caption: "Sin vibes aún")
        }
        return SimpleEntry(date: Date(), imageUrl: first.imageUrl, caption: first.caption)
    }
}

struct WidgetImage: Codable {
    let id: String
    let imageUrl: String
    let senderId: String
    let caption: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageUrl: String
    let caption: String
}

struct VibeShareWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.caption)
                .font(.caption)
                .lineLimit(2)
                .padding(.horizontal, 8)
            
            if !entry.imageUrl.isEmpty {
                Text("📸 Imagen recibida")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            } else {
                Text("Toca para ver vibes")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

@main
struct VibeShareWidget: Widget {
    let kind: String = "VibeShareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VibeShareWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("VibeShare")
        .description("Tus últimas vibes recibidas")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
