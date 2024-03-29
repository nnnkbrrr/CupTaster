//
//  Stopwatch Toolbaritem.swift
//  CupTaster
//
//  Created by Никита on 09.08.2022.
//

import SwiftUI

struct StopwatchToolbarItem: ToolbarContent {
    var placement: ToolbarItemPlacement = .confirmationAction
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            StopwatchView()
        }
    }
}

struct StopwatchView: View {
    @AppStorage("stopwatch-time-since") var timeSince: Date? = nil
    @AppStorage("stopwatch-time-till") var timeTill: Date? = nil
    
    var body: some View {
        ZStack {
            if let timeSince = timeSince {
                label.foregroundColor(.accentColor).overlay {
                    Menu {
                        Button(action: {
                            if let timeTill = timeTill {
                                self.timeSince = Date(timeIntervalSinceNow: timeSince.timeIntervalSince(timeTill))
                                self.timeTill = nil
                            } else {
                                self.timeTill = Date()
                            }
                        }) {
                            switch timeTill {
                            case .none: Label("Stop", systemImage: "pause.fill")
                            case .some: Label("Start", systemImage: "play")
                            }
                        }
                        Button(action: {
                            self.timeSince = nil
                            self.timeTill = nil
                        }) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }
                    } label: { label.opacity(0) }
                }
            } else {
                Button {
                    timeSince = Date()
                } label: { label }
            }
        }
    }
    
    private var label: some View {
        ZStack(alignment: .trailing) {
            TimelineView(.animation) { context in
                if let timeToDisplay: String = getTimeToDisplay() {
                    Text(timeToDisplay)
                        .monospacedDigit()
                } else {
                    Image(systemName: "stopwatch")
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    private func getTimeToDisplay() -> String? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        
        if let timeSince = timeSince {
            if Date(timeIntervalSince1970:
                        Double((timeTill ?? Date()).timeIntervalSince(timeSince))
            ) > Date(timeIntervalSince1970: 3600) {
                self.timeSince = nil
                self.timeTill = nil
            }
            return formatter.string(from: Date(timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince))))
        } else {
            return nil
        }
    }
}
