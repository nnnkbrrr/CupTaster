//
//  Form Section.swift
//  CupTaster
//
//  Created by Никита on 14.08.2022.
//

import SwiftUI

struct InsetFormSection<Header, Content>: View where Header: View, Content: View {
    
    // Variables
    
    @ViewBuilder var content: () -> Content
    var header: () -> Header
    
    // Initialization
    
    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.content = content
        self.header = header
    }
    
    public init<S>(_ title: S, @ViewBuilder content: @escaping () -> Content) where Header == Text, S: StringProtocol {
        self.init { content() } header: { Text(title) }
    }
    
    // Content
    
    var body: some View {
        VStack(spacing: 7) {
            Self.makeHeader { header() }
            Self.makeContent { content() }
        }
    }
    
    private static func makeHeader(content: () -> Header) -> some View {
        content()
            .textCase(.uppercase)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .buttonStyle(AccentForegroundButtonStyle())
            .font(.system(size: 13))
            .padding(.horizontal, 20)
            .frame(height: 20, alignment: .bottom)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    private static func makeContent(content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 44, alignment: .center)
                .padding(.horizontal, 20)
                .overlay(
                    Rectangle()
                        .frame(height: 1, alignment: .bottom)
                        .padding(.leading, 20)
                        .foregroundColor(Color(uiColor: .systemGray5))
                        .offset(y: 1),
                    alignment: .bottom
                )
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
    }
}

// Get only section header or content

extension InsetFormSection where Content == EmptyView {
    static func header(content: () -> Header) -> some View {
        makeHeader(content: content)
    }
}

extension InsetFormSection where Header == EmptyView {
    static func content(content: () -> Content) -> some View {
        makeContent(content: content)
    }
}

// Force foreground buttons color to be accent

private struct AccentForegroundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.foregroundColor(.accentColor)
    }
}

// Apply default link style

public struct InsetFormLinkStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        GeometryReader { geometry in
            HStack {
                configuration.label
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .frame(width: geometry.size.width + 40)
            .frame(height: 44)
            .background(configuration.isPressed ? Color(uiColor: .systemGray4) : nil)
            .offset(x: -20)
        }
    }
}

// Apply button style

public struct InsetFormButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        GeometryReader { geometry in
            HStack {
                configuration.label
                    .foregroundColor(.white)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .frame(width: geometry.size.width + 40)
            .frame(height: 44)
            .background(configuration.isPressed ? Color(uiColor: .systemGray4) : Color.accentColor)
            .offset(x: -20)
        }
    }
}
