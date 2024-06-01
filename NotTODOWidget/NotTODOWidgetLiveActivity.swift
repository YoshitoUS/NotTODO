//
//  NotTODOWidgetLiveActivity.swift
//  NotTODOWidget
//
//  Created by Yoshito Usui on 2024/05/31.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NotTODOWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NotTODOWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NotTODOWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NotTODOWidgetAttributes {
    fileprivate static var preview: NotTODOWidgetAttributes {
        NotTODOWidgetAttributes(name: "World")
    }
}

extension NotTODOWidgetAttributes.ContentState {
    fileprivate static var smiley: NotTODOWidgetAttributes.ContentState {
        NotTODOWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NotTODOWidgetAttributes.ContentState {
         NotTODOWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NotTODOWidgetAttributes.preview) {
   NotTODOWidgetLiveActivity()
} contentStates: {
    NotTODOWidgetAttributes.ContentState.smiley
    NotTODOWidgetAttributes.ContentState.starEyes
}
