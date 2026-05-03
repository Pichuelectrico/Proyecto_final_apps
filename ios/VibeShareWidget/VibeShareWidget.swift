import WidgetKit
import SwiftUI
import UIKit

struct VibeEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let imageData: Data?
}

struct VibeProvider: TimelineProvider {
    func placeholder(in context: Context) -> VibeEntry {
        VibeEntry(date: Date(), title: "VibeShare", subtitle: "Comparte fotos con amigos", imageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (VibeEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VibeEntry>) -> Void) {
        let entry = loadEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30)))
        completion(timeline)
    }

    private func loadEntry() -> VibeEntry {
        let defaults = UserDefaults(suiteName: "group.com.example.flutterBddFirebaseEjm4")
        let imageData = defaults?.data(forKey: "latest_image_data")
        let caption = defaults?.string(forKey: "latest_image_caption")
        let sender = defaults?.string(forKey: "latest_image_sender")
        let senderName = defaults?.string(forKey: "latest_image_sender_name")
        let subtitle: String
        if let senderName = senderName, !senderName.isEmpty {
            subtitle = "De: \(senderName)"
        } else if let sender = sender, !sender.isEmpty {
            subtitle = "De: \(sender)"
        } else if let caption = caption, !caption.isEmpty {
            subtitle = caption
        } else {
            subtitle = "Tu ultima vibe"
        }
        return VibeEntry(
            date: Date(),
            title: "VibeShare",
            subtitle: subtitle,
            imageData: imageData
        )
    }
}

struct VibeShareWidgetEntryView: View {
    var entry: VibeProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.35, blue: 0.85), Color(red: 0.10, green: 0.65, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.white)
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 70)
                        .clipped()
                        .cornerRadius(10)
                }
                Text(entry.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
}

@main
struct VibeShareWidget: Widget {
    let kind: String = "VibeShareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VibeProvider()) { entry in
            VibeShareWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("VibeShare")
        .description("Comparte fotos con tus amigos.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
