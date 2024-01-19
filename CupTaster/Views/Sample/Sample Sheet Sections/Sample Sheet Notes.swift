//
//  Sample Sheet Notes.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

extension SampleBottomSheetView {
    struct SheetNotesSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        var body: some View {
            SampleSheetSection(title: "Notes") {
                ZStack {
                    if let qcGroup: QCGroup = samplesControllerModel.selectedQCGroup {
                        NotesTextField(qcGroup: qcGroup)
                    } else {
                        NotesTextField.Placeholder()
                    }
                }
            }
        }
    }
}

private struct NotesTextField: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var qcGroup: QCGroup
    @State private var height: CGFloat = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).lineHeight
    static let placeholder: String = "What do you taste?"
    
    var body: some View {
        WrappedTextView(text: $qcGroup.notes, placeholder: Self.placeholder, textDidChange: self.textDidChange)
            .frame(height: height)
            .onChange(of: qcGroup.notes) { _ in
                try? moc.save()
            }
    }
    
    private func textDidChange(_ textView: UITextView) {
        self.height = textView.contentSize.height
    }
    
    struct Placeholder: View {
        var body: some View {
            WrappedTextView(text: .constant(""), placeholder: NotesTextField.placeholder, textDidChange: { _ in } )
                .frame(height: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).lineHeight)
        }
    }
}

private struct WrappedTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholderLabel: UILabel!
    let textDidChange: (UITextView) -> Void
    
    init(text: Binding<String>, placeholder: String = "", textDidChange: @escaping (UITextView) -> ()) {
        self._text = text
        self.textDidChange = textDidChange
        
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        placeholderLabel.sizeToFit()
    }

    func makeUIView(context: Context) -> HashtagTextView {
        let view = HashtagTextView()
        view.isEditable = true
        view.delegate = context.coordinator
        
        view.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (view.font?.pointSize)! / 2)
        placeholderLabel.textColor = .gray
        placeholderLabel.isHidden = !text.isEmpty
        
        return view
    }

    func updateUIView(_ uiView: HashtagTextView, context: Context) {
        uiView.text = self.text
        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, placeholderLabelIsHidden: Binding(
            get: { placeholderLabel.isHidden },
            set: { placeholderLabel.isHidden = $0 }
        ), textDidChange: textDidChange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var placeholderLabelIsHidden: Bool
        let textDidChange: (UITextView) -> Void
        
        init(text: Binding<String>, placeholderLabelIsHidden: Binding<Bool>, textDidChange: @escaping (UITextView) -> ()) {
            self._text = text
            self._placeholderLabelIsHidden = placeholderLabelIsHidden
            self.textDidChange = textDidChange
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            placeholderLabelIsHidden = !text.isEmpty
            self.textDidChange(textView)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            placeholderLabelIsHidden = !text.isEmpty
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            placeholderLabelIsHidden = true
        }
    }
}

class HashtagTextView: UITextView {
    #warning("russian letters in regex")
    let hashtagRegex = "#[-_0-9A-Za-z]+"
    
    private var cachedFrames: [CGRect] = []
    private var backgrounds: [UIView] = []
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        self.backgroundColor = .clear
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textUpdated()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func textUpdated() {
        let ranges = resolveHighlightedRanges()
        
        let frames = ranges.compactMap { frame(ofRange: $0) }.reduce([], +)
        
        if cachedFrames != frames {
            cachedFrames = frames
            
            backgrounds.forEach { $0.removeFromSuperview() }
            backgrounds = cachedFrames.map { frame in
                let background = UIView()
                background.backgroundColor = UIColor(Color.accentColor)
                background.frame = frame
                background.layer.cornerRadius = 5
                insertSubview(background, at: 0)
                return background
            }
        }
    }
    
    private func configureView() {
        NotificationCenter.default.addObserver(self, selector: #selector(textUpdated), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func resolveHighlightedRanges() -> [NSRange] {
        guard text != nil, let regex = try? NSRegularExpression(pattern: hashtagRegex, options: []) else { return [] }
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in: text))
        let ranges = matches.map { $0.range }
        return ranges
    }
}

private extension UITextView {
    func convertRange(_ range: NSRange) -> UITextRange? {
        let beginning = beginningOfDocument
        if let start = position(from: beginning, offset: range.location), let end = position(from: start, offset: range.length) {
            let resultRange = textRange(from: start, to: end)
            return resultRange
        } else {
            return nil
        }
    }
    
    func frame(ofRange range: NSRange) -> [CGRect]? {
        if let textRange = convertRange(range) {
            let rects = selectionRects(for: textRange)
            return rects.map { $0.rect }
        } else {
            return nil
        }
    }
}
