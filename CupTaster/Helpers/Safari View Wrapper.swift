//
//  Safari View Wrapper.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.04.2023.
//

import SwiftUI
import SafariServices

struct SFSafariViewWrapper: UIViewControllerRepresentable {
	let url: URL
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}
	
	func updateUIViewController(
		_ uiViewController: SFSafariViewController,
		context: UIViewControllerRepresentableContext<SFSafariViewWrapper>
	) {
		return
	}
}
