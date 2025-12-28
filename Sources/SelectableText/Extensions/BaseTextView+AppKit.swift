//
//  BaseTextView+AppKit.swift
//
//
//  Created by Kevin Hermawan on 14/02/24.
//

#if canImport(AppKit)
import AppKit
import SwiftUI

class BaseTextView: NSTextView {
    var maxLayoutWidth: CGFloat = 0 {
        didSet {
            guard maxLayoutWidth != oldValue else { return }
            
            self.textContainer?.containerSize = CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
            invalidateIntrinsicContentSize()
        }
    }

    var onWordTapped: ((String) -> Void)?

    override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting: Bool) {
        super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelecting)
        
        if !stillSelecting && charRange.length == 0 {
            guard let onWordTapped = onWordTapped,
                  let textStorage = self.textStorage,
                  charRange.location < textStorage.length else { return }
            
            let text = textStorage.string as NSString
            let wordRange = text.rangeOfWord(at: charRange.location)
            
            guard wordRange.location != NSNotFound, wordRange.length > 0 else { return }
            
            let word = text.substring(with: wordRange)
            onWordTapped(word)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard maxLayoutWidth > 0 else {
            return super.intrinsicContentSize
        }
        
        guard let textContainer = self.textContainer, let layoutManager = self.layoutManager else {
            return super.intrinsicContentSize
        }
        
        textContainer.containerSize = CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
        textContainer.widthTracksTextView = true
        
        layoutManager.ensureLayout(for: textContainer)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        return CGSize(width: ceil(textBoundingBox.size.width), height: ceil(textBoundingBox.size.height))
    }
}

private extension NSString {
    func rangeOfWord(at index: Int) -> NSRange {
        let options: NSString.EnumerationOptions = .byWords
        var wordRange = NSRange(location: NSNotFound, length: 0)

        enumerateSubstrings(
            in: NSRange(location: 0, length: length),
            options: options
        ) { _, substringRange, _, stop in
            if NSLocationInRange(index, substringRange) {
                wordRange = substringRange
                stop.pointee = true
            }
        }

        return wordRange
    }
}
#endif
