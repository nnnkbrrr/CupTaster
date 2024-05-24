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
        @State private var height: CGFloat = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).lineHeight
        
        var body: some View {
            SampleSheetSection(title: "Notes") {
                NotesTextFieldView(
                    text: Binding(
                        get: { samplesControllerModel.selectedQCGroup?.notes ?? "" },
                        set: { samplesControllerModel.selectedQCGroup?.notes = $0 }
                    ),
                    updateViewHeight: self.updateViewHeight
                )
                .frame(height: height)
            }
        }
        
        private func updateViewHeight(_ height: CGFloat) {
            self.height = height
        }
    }
}

private struct NotesTextFieldView: UIViewRepresentable {
    @Environment(\.managedObjectContext) private var moc
    @Binding var text: String
    var placeholderLabel: UILabel!
    let updateViewHeight: (CGFloat) -> ()
    
    init(text: Binding<String>, updateViewHeight: @escaping (CGFloat) -> ()) {
        self._text = text
        self.updateViewHeight = updateViewHeight
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "What do you taste?"
        placeholderLabel.font = HashtagTextView.font
        placeholderLabel.textColor = .gray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: HashtagTextView.font.pointSize / 2)
    }

    func makeUIView(context: Context) -> HashtagTextView {
        let view = HashtagTextView()
        view.isEditable = true
        view.delegate = context.coordinator
        view.addSubview(placeholderLabel)
        updatePlaceholderVisibility(view)
        
        return view
    }

    func updateUIView(_ uiView: HashtagTextView, context: Context) {
        uiView.text = text
        updatePlaceholderVisibility(uiView)
        
        DispatchQueue.main.async {
            self.updateViewHeight(uiView.contentSize.height)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: NotesTextFieldView
        
        init(_ parent: NotesTextFieldView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.updatePlaceholderVisibility(textView)
            parent.updateViewHeight(textView.contentSize.height)
            save(parent.moc)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.updatePlaceholderVisibility(textView)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.updatePlaceholderVisibility(textView, isHidden: true)
        }
    }
    
    private func updatePlaceholderVisibility(_ view: UITextView, isHidden value: Bool? = nil) {
        let label: UIView? = view.subviews.filter { $0 is UILabel }.first
        label?.isHidden = value ?? !text.isEmpty
    }
}

class HashtagTextView: UITextView {
    static let font: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
    let hashtagRegex = "#[-_0-9A-Za-z]+"
    
    private var cachedFrames: [CGRect] = []
    private var backgrounds: [UIView] = []
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = Self.font
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
