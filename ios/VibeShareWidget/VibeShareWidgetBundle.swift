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
        SimpleEntry(date: Date(), imageUrl: "", caption: "VibeShare", senderName: "Amigo")
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
        // IMPORTANTE: Este App Group debe coincidir con el de Flutter
        // Configurarlo en Xcode: Signing & Capabilities → App Groups
        guard let defaults = UserDefaults(suiteName: "group.com.example.flutterBddFirebaseEjm40"),
              let jsonString = defaults.string(forKey: "latest_images"),
              let data = jsonString.data(using: .utf8),
              let images = try? JSONDecoder().decode([WidgetImage].self, from: data),
              let first = images.first else {
            return SimpleEntry(date: Date(), imageUrl: "", caption: "Sin vibes aún", senderName: "")
        }
        return SimpleEntry(date: Date(), imageUrl: first.imageUrl, caption: first.caption, senderName: first.senderName)
    }
}

struct WidgetImage: Codable {
    let id: String
    let imageUrl: String
    let senderId: String
    let senderName: String
    let caption: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageUrl: String
    let caption: String
    let senderName: String
}

struct VibeShareWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header con nombre del remitente
            if !entry.senderName.isEmpty {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.green)
                    Text(entry.senderName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            
            // Mostrar imagen si hay URL
            if !entry.imageUrl.isEmpty, let url = URL(string: entry.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: family == .systemSmall ? 50 : 80)
                            .clipped()
                            .cornerRadius(8)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: family == .systemSmall ? 50 : 80)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxHeight: family == .systemSmall ? 50 : 80)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Caption
            Text(entry.caption)
                .font(family == .systemSmall ? .caption2 : .caption)
                .fontWeight(.medium)
                .lineLimit(family == .systemSmall ? 1 : 2)
                .padding(.horizontal, 8)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 4)
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
