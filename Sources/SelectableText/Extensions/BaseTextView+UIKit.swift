//
//  BaseTextView+UIKit.swift
//
//
//  Created by Kevin Hermawan on 14/02/24.
//

#if canImport(UIKit)
import SwiftUI

class BaseTextView: UITextView {
    var maxLayoutWidth: CGFloat = 0 {
        didSet {
            guard maxLayoutWidth != oldValue else { return }
            
            invalidateIntrinsicContentSize()
        }
    }

    var onWordTapped: ((String) -> Void)?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGesture()
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard onWordTapped != nil else { return }

        // When user are selecting text, don't trigger word tap
        if let selectedRange = selectedTextRange, !selectedRange.isEmpty {
            return
        }

        let location = gesture.location(in: self)
        guard let word = word(at: location) else { return }
        onWordTapped?(word)
    }

    private func word(at point: CGPoint) -> String? {
        guard let position = closestPosition(to: point) else { return nil }
        guard let range = tokenizer.rangeEnclosingPosition(
            position,
            with: .word,
            inDirection: UITextDirection(rawValue: UITextLayoutDirection.left.rawValue)
        ) else { return nil }

        return text(in: range)
    }
    
    override var intrinsicContentSize: CGSize {
        guard maxLayoutWidth > 0 else {
            return super.intrinsicContentSize
        }
        
        return sizeThatFits(
            CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
        )
    }
}

extension BaseTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
#endif
