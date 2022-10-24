//
//  Half Sheet.swift
//  CupTaster
//
//  Created by Никита on 26.09.2022.
//

import SwiftUI

private class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = [.medium()]
        }
    }
}

private struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {
    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) { }
}

struct HalfSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var interactiveDismissDisabled: Bool
    @ViewBuilder var sheetContent: () -> SheetContent
    
    init(
        isPresented: Binding<Bool>,
        interactiveDismissDisabled: Binding<Bool> = .constant(false),
        content sheetContent: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self._interactiveDismissDisabled = interactiveDismissDisabled
        self.sheetContent = sheetContent
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                HalfSheet { sheetContent() }
                    .interactiveDismissDisabled(interactiveDismissDisabled)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func halfSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        interactiveDismissDisabled: Binding<Bool> = .constant(false),
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(HalfSheetModifier(
            isPresented: isPresented,
            interactiveDismissDisabled: interactiveDismissDisabled,
            content: content
        ))
    }
}
