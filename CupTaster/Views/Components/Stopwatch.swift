//
//  Stopwatch Toolbaritem.swift
//  CupTaster
//
//  Created by Никита on 09.08.2022.
//

import SwiftUI

struct StopwatchView: View {
    @AppStorage("stopwatch-time-since") var timeSince: Date? = nil
    @AppStorage("stopwatch-time-till") var timeTill: Date? = nil
    
    #warning("it works like shit")
    @State var showConfirmationDialog: Bool = false
    
    var body: some View {
        TimelineView(.animation) { _ in
            if let timeToDisplay: String = getTimeToDisplay() {
                Text(timeToDisplay)
                    .monospacedDigit()
            } else {
                Image(systemName: "stopwatch")
            }
        }
        .contentShape(Rectangle())
        .foregroundColor(.accentColor)
        .onTapGesture {
            if timeSince != nil && timeTill != nil {
                showConfirmationDialog = true
            } else if timeSince == nil {
                timeSince = Date()
            } else {
                timeTill = Date()
            }
        }
        .confirmationDialog(
            "Stopwatch: \(getTimeToDisplay() ?? "--:--.--")",
            isPresented: $showConfirmationDialog) {
                if let timeSince, let timeTill {
                    Button("Start") {
                        self.timeSince = Date(timeIntervalSinceNow: timeSince.timeIntervalSince(timeTill))
                        self.timeTill = nil
                    }
                }
                Button("Reset", role: .destructive) {
                    self.timeSince = nil
                    self.timeTill = nil
                }
            }
    }
    
    private func getTimeToDisplay() -> String? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        
        if let timeSince = timeSince {
            if Date(timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince))) > Date(timeIntervalSince1970: 3600) {
                self.timeSince = nil
                self.timeTill = nil
            }
            return formatter.string(from: Date(timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince))))
        } else {
            return nil
        }
    }
}

// ToolbarItem Modifier

struct StopwatchToolbarItemModifier: ViewModifier {
    var placement: ToolbarItemPlacement = .confirmationAction
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    StopwatchView()
                }
            }
    }
}

extension View {
    func stopwatchToolbarItem(placement: ToolbarItemPlacement = .confirmationAction) -> some View {
        modifier(StopwatchToolbarItemModifier(placement: placement))
    }
}
