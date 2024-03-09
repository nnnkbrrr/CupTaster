//
//  Modal View.swift
//  CupTaster
//
//  Created by Nikita on 03.03.2024.
//

import SwiftUI

extension View {
    func modalView<ModalContent: View>(
        isPresented: Binding<Bool>,
        toolbar: ModalViewToolbarView,
        content: @escaping () -> ModalContent
    ) -> some View {
        return modifier(ModalView(isPresented: isPresented, toolbar: toolbar, content: content))
    }
}

struct ModalView<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toolbar: ModalViewToolbarView
    let modalContent: () -> ModalContent
    
    init(isPresented: Binding<Bool>, toolbar: ModalViewToolbarView, content: @escaping () -> ModalContent) {
        self._isPresented = isPresented
        self.toolbar = toolbar
        self.modalContent = content
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ScrollView {
                    modalContent()
                }
                .background(Color.backgroundPrimary)
                .safeAreaInset(edge: .top) {
                    toolbar
                        .frame(height: 44)
                        .background {
                            ZStack {
                                Color.backgroundPrimary.opacity(0.5)
                                TransparentBlurView()
                            }
                            .edgesIgnoringSafeArea(.top)
                        }
                }
            }
    }
}

struct ModalViewToolbarView: View {
    class FullScreenToolbarButton {
        let label: String
        let action: () -> ()
        
        init(_ label: String, action: @escaping () -> Void) {
            self.label = label
            self.action = action
        }
    }
    
    let leadingToolbarItem: FullScreenToolbarButton?
    let title: String
    let trailingToolbarItem: FullScreenToolbarButton
    
    init(leadingToolbarItem: FullScreenToolbarButton? = nil, title: String, trailingToolbarItem: FullScreenToolbarButton) {
        self.leadingToolbarItem = leadingToolbarItem
        self.title = title
        self.trailingToolbarItem = trailingToolbarItem
    }
    
    var body: some View {
        ZStack {
            if let leadingToolbarItem {
                Button {
                    leadingToolbarItem.action()
                } label: {
                    Text(leadingToolbarItem.label)
                        .padding([.vertical, .trailing], .small)
                        .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, alignment: leadingToolbarItem == nil ? .leading : .center)
            
            Button {
                trailingToolbarItem.action()
            } label: {
                Text(trailingToolbarItem.label)
                    .padding([.vertical, .leading], .small)
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, .small)
    }
}
