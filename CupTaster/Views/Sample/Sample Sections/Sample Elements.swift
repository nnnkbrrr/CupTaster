//
//  Sample Elements.swift
//  CupTaster
//
//  Created by Nikita on 08.01.2024.
//

import SwiftUI

struct SampleToolsSection: View {
    let tools: [SampleTool]
    private static let dividerWidth: CGFloat = 3
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: -Self.dividerWidth) {
                ForEach(tools) { tool in
                    SampleToolButton(tool)
                    
                    if tool.id != tools.last?.id {
                        ToolsDivider()
                    }
                }
            }
        }
    }
    
    class SampleTool: Identifiable {
        let systemImageName: String
        let disabled: Bool
        let action: () -> ()
        
        init(systemImageName: String, disabled: Bool = false, action: @escaping () -> Void) {
            self.systemImageName = systemImageName
            self.disabled = disabled
            self.action = action
        }
    }
    
    private struct SampleToolButton: View {
        let sampleTool: SampleTool
        
        init(_ sampleTool: SampleTool) {
            self.sampleTool = sampleTool
        }
        
        var body: some View {
            Button {
                sampleTool.action()
            } label: {
                Image(systemName: sampleTool.systemImageName)
                    .font(.title2)
            }
            .buttonStyle(SampleToolButtonStyle())
            .disabled(sampleTool.disabled)
        }
    }

    private struct ToolsDivider: View {
        var body: some View {
            Rectangle()
                .foregroundStyle(Color.backgroundTertiary)
                .frame(width: dividerWidth)
                .padding(.vertical, .regular)
        }
    }
    
    private struct SampleToolButtonStyle: ButtonStyle {
        let width: CGFloat?
        let height: CGFloat?
        
        init(width: CGFloat? = nil, height: CGFloat? = nil) {
            self.width = width
            self.height = height
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundTertiary.opacity(configuration.isPressed ? 1 : 0))
                .contentShape(Rectangle())
        }
    }
}

struct SampleBlockModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: width == nil ? .infinity : nil, maxHeight: height == nil ? .infinity : nil)
            .frame(width: width, height: height)
            .background(Color.backgroundSecondary)
            .cornerRadius()
    }
}

extension View {
    func sampleBlock(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        modifier(SampleBlockModifier(width: width, height: height))
    }
}

struct SampleBlockButtonStyle: ButtonStyle {
    let width: CGFloat?
    let height: CGFloat?
    
    init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: width == nil ? .infinity : nil, maxHeight: height == nil ? .infinity : nil)
            .frame(width: width, height: height)
            .background(configuration.isPressed ? Color.backgroundTertiary : .backgroundSecondary)
            .cornerRadius()
    }
}

extension ButtonStyle where Self == SampleBlockButtonStyle {
    static func sampleBlock(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        return .init(width: width, height: height)
    }
}
