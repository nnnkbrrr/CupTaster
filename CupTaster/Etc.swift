//
//  Etc.swift
//  CupTaster
//
//  Created by Никита on 09.04.2022.
//

import SwiftUI
import CoreData

// MARK: Blur

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: Text editor background

extension View {
    func textEditorBackgroundColor(_ color: UIColor) -> some View {
        self.onAppear { UITextView.appearance().backgroundColor = color }
    }
}

// MARK: Navigation Link Button

struct NavigationLinkButton<Label: View, Destination: View>: View {
    let destination: Destination
    @ViewBuilder var label: Label

    init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    @State var isActive: Bool = false

    var body: some View {
        Button {
            isActive = true
        } label: {
            label
        }
        .background (
            NavigationLink(destination: destination, isActive: $isActive) {
                EmptyView()
            }.hidden()
        )
    }
}

// MARK: Extend AppStorage

extension Date: RawRepresentable {
    fileprivate static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

extension Optional: RawRepresentable where Wrapped == Date {
    public var rawValue: String {
        if let self = self {
            return Date.formatter.string(from: self)
        } else {
            return ""
        }
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? nil
    }
}

// MARK: Format checkboxes value

func getCheckboxesRepresentationValue(value: CGFloat, cupsCount: Int) -> String {
    let value: CGFloat = 10.0 - (10.0 * CGFloat("\(value)".components(separatedBy: "1").count - 1)) / CGFloat(cupsCount)
    switch value.truncatingRemainder(dividingBy: 1) {
        case 0: return String(format: "%.0f", value)
        default: return String(format: "%.1f", value)
    }
}

// MARK: Navigation Button

struct NavigationButton<Destination: View, Label: View>: View {
    var action: () -> Void
    var destination: () -> Destination
    var label: () -> Label
    
    @State private var isActive: Bool = false
    
    var body: some View {
        Button(action: {
            self.action()
            self.isActive.toggle()
        }) {
            self.label()
                .background(
                    ScrollView {
                        NavigationLink(
                            destination: LazyDestination { self.destination() },
                            isActive: self.$isActive) { EmptyView() }
                    }
                )
        }
    }
}

struct LazyDestination<Destination: View>: View {
    var destination: () -> Destination
    var body: some View {
        self.destination()
    }
}

// MARK: Transparent Navigation Bar Background

extension UINavigationBar {
    static func setTransparentBackground() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        self.appearance().compactAppearance = appearance
        self.appearance().standardAppearance = appearance
        self.appearance().scrollEdgeAppearance = appearance
        self.appearance().compactScrollEdgeAppearance = appearance
    }
}
