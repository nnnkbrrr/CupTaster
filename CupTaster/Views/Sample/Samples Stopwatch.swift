//
//  Samples Stopwatch.swift
//  CupTaster
//
//  Created by Nikita on 07.02.2024.
//

import SwiftUI

struct SampleStopwatchView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var stopwatchModel: StopwatchModel = .shared
    
    var body: some View {
        var stopwatchId: String {
            guard let selectedSample = SamplesControllerModel.shared.selectedSample else { return "" }
            return "\(selectedSample.id).page.container"
        }
        
        VStack(spacing: .small) {
            TimelineView(.animation) { _ in
                Text(stopwatchModel.timeToDisplay)
                    .monospacedDigit()
                    .resizableText(initialSize: 100, weight: .light)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
            }
            
            HStack(spacing: .small) {
                Button {
                    withAnimation(.bouncy(duration: 0.4)) {
                        samplesControllerModel.stopwatchOverlayIsActive = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 50, height: 50)
                        .background(Color.backgroundTertiary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Button {
                    stopwatchModel.state == .started ? stopwatchModel.stop() : stopwatchModel.start()
                } label: {
                    Image(systemName: stopwatchModel.state == .started ? "stop.fill" : "play.fill")
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(stopwatchModel.state == .started ? Color.red : .green)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Button {
                    stopwatchModel.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 50, height: 50)
                        .background(Color.backgroundTertiary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.backgroundSecondary)
                .matchedGeometryEffect(
                    id: stopwatchId,
                    in: NamespaceControllerModel.shared.namespace
                )
        )
    }
}
