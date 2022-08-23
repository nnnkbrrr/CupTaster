//
//  Stopwatch Toolbaritem.swift
//  CupTaster
//
//  Created by Никита on 09.08.2022.
//

import SwiftUI

struct StopwatchToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
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
                Menu {
                    Button(action: {
                        if let timeTill = timeTill {
                            self.timeSince = Date(timeIntervalSinceNow: timeSince.timeIntervalSince(timeTill))
                            self.timeTill = nil
                        } else {
                            self.timeTill = Date()
                        }
                    }) {
                        if timeTill == nil {
                            Label("Stop", systemImage: "pause.fill")
                        } else {
                            Label("Start", systemImage: "play")
                        }
                    }
                    Button(action: {
                        self.timeSince = nil
                        self.timeTill = nil
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                } label: { label }
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
                let timeToDisplay: String? = getTimeToDisplay()
                
                Text(timeToDisplay ?? "")
                    .font(.custom("Menlo-Regular", size: 17))
                    .frame(width: 100, alignment: .trailing)
            }
            
            if timeSince == nil {
                Image(systemName: "stopwatch")
                    .frame(width: 100, alignment: .trailing)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func getTimeToDisplay() -> String? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        
        if let timeSince = timeSince {
            return formatter.string(
                from: Date(
                    timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince))
                )
            )
        } else {
            return nil
        }
    }
}
