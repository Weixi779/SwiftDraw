//
//  LayerTree.Builder.Layer.swift
//  SwiftDraw
//
//  Created by Simon Whitty on 21/11/18.
//  Copyright 2020 WhileLoop Pty Ltd. All rights reserved.
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/swhitty/SwiftDraw
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import SwiftDrawDOM
import Foundation

extension LayerTree.Builder {

    func makeShapeContents(from shape: LayerTree.Shape, with state: State) -> LayerTree.Layer.Contents {
        let stroke = makeStrokeAttributes(with: state)
        let fill = makeFillAttributes(with: state)
        return .shape(shape, stroke, fill)
    }

    func makeUseLayerContents(from use: DOM.Use, with state: State) throws -> LayerTree.Layer.Contents {
        guard
            let id = use.href.fragmentID,
            let element = svg.firstGraphicsElement(with: id) else {
            throw LayerTree.Error.invalid("missing referenced element: \(use.href)")
        }

        let l = makeLayer(from: element, inheriting: state)
        let x = use.x ?? 0.0
        let y = use.y ?? 0.0

        if x != 0 || y != 0 {
            l.transform.insert(.translate(tx: x, ty: y), at: 0)
        }

        return .layer(l)
    }

    static func makeTextContents(from text: DOM.Text, with state: State) -> LayerTree.Layer.Contents {
        var point = Point(text.x ?? 0, text.y ?? 0)
        var att = makeTextAttributes(with: state)
        att.fontName = text.attributes.fontFamily ?? att.fontName
        att.size = text.attributes.fontSize ?? att.size
        att.anchor = text.attributes.textAnchor ?? att.anchor
        
        // Apply CJK font fallback if needed
        att.fontName = applyCJKFontFallback(fontName: att.fontName, text: text.value)
        
        point.x += makeXOffset(for: text.value, with: att)
        return .text(text.value, point, att)
    }
    
    /// Apply CJK font fallback for better text rendering
    static func applyCJKFontFallback(fontName: String, text: String) -> String {
        // Check if text contains CJK characters
        let containsCJK = text.range(of: "[\\u4E00-\\u9FFF\\u3400-\\u4DBF\\u3040-\\u309F\\u30A0-\\u30FF\\uAC00-\\uD7AF]", options: .regularExpression) != nil
        
        // Only apply CJK font fallback if text actually contains CJK characters
        if containsCJK {
            return getBestCJKFont(for: text, basedOn: fontName)
        }
        
        // For non-CJK text, keep original font
        return fontName
    }
    
    /// Get the best CJK font based on the text content and region
    static func getBestCJKFont(for text: String, basedOn fontName: String) -> String {
        // Detect primary script type
        let hasChineseSimplified = text.range(of: "[\\u4E00-\\u9FFF]", options: .regularExpression) != nil
        let hasJapanese = text.range(of: "[\\u3040-\\u309F\\u30A0-\\u30FF]", options: .regularExpression) != nil  
        let hasKorean = text.range(of: "[\\uAC00-\\uD7AF]", options: .regularExpression) != nil
        
        // If already a good CJK font, keep it
        if fontName.contains("PingFang") || fontName.contains("Hiragino") || 
           fontName.contains("STHeiti") || fontName.contains("Apple SD Gothic") ||
           fontName.contains("SF") {
            return fontName
        }
        
        // Choose best font based on script and style
        #if os(iOS)
        if hasKorean {
            return fontName.lowercased().contains("serif") ? "Apple SD Gothic Neo" : "Apple SD Gothic Neo"
        } else if hasJapanese {
            return fontName.lowercased().contains("serif") ? "Hiragino Mincho ProN" : "Hiragino Sans"
        } else if hasChineseSimplified {
            return fontName.lowercased().contains("serif") ? "Songti SC" : "PingFang SC"
        } else {
            // Default fallback for mixed or unknown CJK
            return "PingFang SC"
        }
        #else
        // macOS similar logic
        if hasKorean {
            return "Apple SD Gothic Neo"
        } else if hasJapanese {
            return fontName.lowercased().contains("serif") ? "Hiragino Mincho ProN" : "Hiragino Sans"
        } else if hasChineseSimplified {
            return fontName.lowercased().contains("serif") ? "Songti SC" : "PingFang SC"
        } else {
            return "PingFang SC"
        }
        #endif
    }

    static func makeImageContents(from image: DOM.Image) throws -> LayerTree.Layer.Contents {
        guard
            let decoded = image.href.decodedData,
            var im = LayerTree.Image(mimeType: decoded.mimeType, data: decoded.data) else {
            throw LayerTree.Error.invalid("Cannot decode image")
        }

        im.origin.x = LayerTree.Float(image.x ?? 0)
        im.origin.y = LayerTree.Float(image.y ?? 0)
        im.width = image.width.map { LayerTree.Float($0) }
        im.height = image.height.map { LayerTree.Float($0) }

        return .image(im)
    }
}
