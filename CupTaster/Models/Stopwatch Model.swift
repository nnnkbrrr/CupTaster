//
//  Stopwatch Model.swift
//  CupTaster
//
//  Created by Nikita on 08.02.2024.
//

import SwiftUI

class StopwatchModel: ObservableObject {
    @AppStorage("stopwatch-reset-in-1h") public var resetInAnHour: Bool = true
    @AppStorage("stopwatch-time-since") fileprivate var timeSince: Date? = nil
    @AppStorage("stopwatch-time-till") fileprivate var timeTill: Date? = nil
    
    enum State { case idle, started, stopped }
    @Published fileprivate(set) var state: State
    
    static let shared: StopwatchModel = .init()
    private init() {
        self.state = {
            guard UserDefaults.standard.string(forKey: "stopwatch-time-since") != "" else { return.idle }
            guard UserDefaults.standard.string(forKey: "stopwatch-time-till") != "" else { return .started }
            return .stopped
        }()
        
        if let timeSince {
            let resetInAnHour: Bool = resetInAnHour && timeSince.timeIntervalSinceNow < -60 * 60
            let forceResetInADay: Bool = timeSince.timeIntervalSince(timeTill ?? Date()) < -60 * 60 * 24
            if resetInAnHour || forceResetInADay { reset() }
        }
    }
    
    // variables
    
    private var minutesFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "mm"
        return formatter
    }
    
    private var secondsFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "ss.SS"
        return formatter
    }
    
    private var timeToDisplayFormatter: DateFormatter {
        var hoursIndicator: String {
            if let timeSince, timeSince.timeIntervalSince(timeTill ?? Date()) < -3600 { return "HH:" }
            else { return ""}
        }
        let formatter: DateFormatter = .init()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "\(hoursIndicator)mm:ss.SS"
        return formatter
    }
    
    private var stopwatchDate: Date? {
        guard let timeSince else { return nil }
        return Date(timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince)))
    }
    
    public var minutes: Int {
        guard let stopwatchDate else { return 0 }
        return Int(minutesFormatter.string(from: stopwatchDate)) ?? 0
    }
    
    public var seconds: Double {
        guard let stopwatchDate else { return 0 }
        return Double(secondsFormatter.string(from: stopwatchDate)) ?? 0
    }
    
    public var timeToDisplay: String {
        guard let stopwatchDate else { return "00:00.00" }
        return timeToDisplayFormatter.string(from: stopwatchDate)
    }
    
    // functions
    
    public func start() {
        if let timeSince, let timeTill {
            self.timeSince = Date(timeIntervalSinceNow: timeSince.timeIntervalSince(timeTill))
            self.timeTill = nil
        } else {
            self.timeSince = Date()
        }
        self.state = .started
    }
    
    public func stop() {
        self.timeTill = Date()
        self.state = .stopped
    }
    
    public func reset() {
        self.timeSince = nil
        self.timeTill = nil
        self.state = .idle
    }
}

// Tester

struct StopwatchTimeSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var stopwatchModel: StopwatchModel = .shared
    
    @State var hours: Int = 0
    @State var minutes: Int
    @State var seconds: Int
    
    init() {
        self._minutes = State(initialValue: StopwatchModel.shared.minutes)
        self._seconds = State(initialValue: Int(StopwatchModel.shared.seconds))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TimelineView(.animation) { _ in
                Text(stopwatchModel.timeToDisplay)
                    .monospacedDigit()
                    .resizableText(initialSize: 100, weight: .light)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            Text("Hours")
            
            TargetHorizontalScrollView(
                (0...23), selection: $hours, elementWidth: 25, height: 20, spacing: 10
            ) { hour in
                Text("\(hour)")
                    .font(.headline)
                    .frame(width: 25, height: 20)
                    .foregroundStyle(hours == hour ? Color.primary : .gray)
            }
            
            Divider()
            
            Text("Minutes")
            
            TargetHorizontalScrollView(
                (0...59), selection: $minutes, elementWidth: 25, height: 20, spacing: 10
            ) { minute in
                Text("\(minute)")
                    .font(.headline)
                    .frame(width: 25, height: 20)
                    .foregroundStyle(minutes == minute ? Color.primary : .gray)
            }
            
            Divider()
            
            Text("Seconds")
            
            TargetHorizontalScrollView(
                (0...59), selection: $seconds, elementWidth: 25, height: 20, spacing: 10
            ) { second in
                Text("\(second)")
                    .font(.headline)
                    .frame(width: 25, height: 20)
                    .foregroundStyle(seconds == second ? Color.primary : .gray)
            }
            
            Divider()
            
            HStack {
                Group {
                    Text("\(stopwatchModel.timeSince?.formatted(date: .numeric, time: .standard) ?? "--")")
                        .frame(maxWidth: .infinity)
                    Text("->")
                    Text("\(stopwatchModel.timeTill?.formatted(date: .numeric, time: .standard) ?? "--")")
                        .frame(maxWidth: .infinity)
                }
                .font(.caption2)
                .foregroundStyle(.gray)
            }
            
            Divider()
            
            HStack {
                Button(stopwatchModel.state == .started ? "STOP" : "START") {
                    stopwatchModel.state == .started ? stopwatchModel.stop() : stopwatchModel.start()
                }
                .buttonStyle(.primary)
                
                
                Button("RESET") {
                    stopwatchModel.reset()
                }
                .buttonStyle(.primary)
                
                Button("SET") {
                    stopwatchModel.timeSince = Date(timeIntervalSinceNow: TimeInterval(-(seconds + minutes * 60 + hours * 60 * 60)))
                    stopwatchModel.timeTill = Date()
                    stopwatchModel.state = .stopped
                }
                .buttonStyle(.primary)
            }
        }
        .font(.body)
        .padding(.horizontal)
    }
}
