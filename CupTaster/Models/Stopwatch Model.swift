//
//  Stopwatch Model.swift
//  CupTaster
//
//  Created by Nikita on 08.02.2024.
//

import SwiftUI

class StopwatchModel: ObservableObject {
    @AppStorage("stopwatch-time-since") private var timeSince: Date? = nil
    @AppStorage("stopwatch-time-till") private var timeTill: Date? = nil
    
    enum State { case idle, started, stopped }
    @Published public var state: State
    
    static let shared: StopwatchModel = .init()
    private init() {
        self.state = {
            if UserDefaults.standard.string(forKey: "stopwatch-time-since") != "" {
                if UserDefaults.standard.string(forKey: "stopwatch-time-till") != "" {
                    return .stopped
                }
                return .started
            }
            return.idle
        }()
        
        if let timeSince {
            if Date(timeIntervalSince1970: Double((timeTill ?? Date()).timeIntervalSince(timeSince))) > Date(timeIntervalSince1970: 3600) {
                self.timeSince = nil
                self.timeTill = nil
                self.state = .idle
            }
        }
    }
    
    // variables
    
    private var minutesFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "mm"
        return formatter
    }
    
    private var secondsFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "ss.SS"
        return formatter
    }
    
    private var timeToDisplayFormatter: DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "mm:ss.SS"
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
