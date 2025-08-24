//
//  TextRenderingTests.swift
//  SwiftDraw
//
//  Created for MathJax CJK support verification
//

@testable import SwiftDraw
import XCTest

final class TextRenderingTests: XCTestCase {
    
    // MARK: - Basic Text Rendering Tests
    
    func testEnglishTextRendering() throws {
        let svgContent = """
        <svg width="200" height="60" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="30" font-family="Helvetica" font-size="16" fill="black">Hello World</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "English text should render successfully")
        XCTAssertEqual(svg.size.width, 200)
        XCTAssertEqual(svg.size.height, 60)
    }
    
    func testNumbersRendering() throws {
        let svgContent = """
        <svg width="200" height="60" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="30" font-family="Helvetica" font-size="16" fill="black">1234567890</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Numbers should render successfully")
    }
    
    func testMathSymbolsRendering() throws {
        let svgContent = """
        <svg width="200" height="60" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="30" font-family="Times" font-size="16" fill="black">+-*/=()[]</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Math symbols should render successfully")
    }
    
    // MARK: - CJK Text Rendering Tests
    
    func testChineseTextRendering() throws {
        let svgContent = """
        <svg width="300" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-family="PingFang SC" font-size="18" fill="black">任意非零倍数</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Chinese text should render without crashing")
        // Note: We're not testing visual correctness, just that it doesn't crash
    }
    
    func testJapaneseTextRendering() throws {
        let svgContent = """
        <svg width="300" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-family="Hiragino Sans" font-size="18" fill="black">数学公式</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Japanese text should render without crashing")
    }
    
    func testKoreanTextRendering() throws {
        let svgContent = """
        <svg width="300" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-family="Apple SD Gothic Neo" font-size="18" fill="black">수학 공식</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Korean text should render without crashing")
    }
    
    // MARK: - Large Font Size Tests (MathJax Style)
    
    func testLargeFontEnglish() throws {
        let svgContent = """
        <svg width="400" height="200" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="100" font-family="Times" font-size="72" fill="black">X</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Large font English should render successfully")
    }
    
    func testLargeFontChinese() throws {
        let svgContent = """
        <svg width="400" height="200" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="100" font-family="PingFang SC" font-size="72" fill="black">数</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Large font Chinese should render without crashing")
    }
    
    // MARK: - Mixed Content Tests
    
    func testMixedEnglishChinese() throws {
        let svgContent = """
        <svg width="400" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-family="PingFang SC" font-size="16" fill="black">Hello 你好 123</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Mixed English/Chinese/Numbers should render")
    }
    
    // MARK: - MathJax Style Transform Tests
    
    func testTransformScale() throws {
        let svgContent = """
        <svg width="200" height="100" xmlns="http://www.w3.org/2000/svg">
          <g transform="scale(1,-1)">
            <text x="10" y="-50" font-family="Times" font-size="16" fill="black" transform="scale(1,-1)">Test</text>
          </g>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Transform scale should not crash")
    }
    
    // MARK: - Font Fallback Tests
    
    func testSerifFontFallback() throws {
        let svgContent = """
        <svg width="300" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-family="serif" font-size="16" fill="black">任意非零倍数</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Serif font should fallback for CJK text")
    }
    
    func testEmptyFontFallback() throws {
        let svgContent = """
        <svg width="300" height="80" xmlns="http://www.w3.org/2000/svg">
          <text x="10" y="40" font-size="16" fill="black">任意非零倍数</text>
        </svg>
        """
        
        let svg = try XCTUnwrap(SVG(xml: svgContent))
        let image = svg.rasterize()
        
        XCTAssertNotNil(image, "Empty font should fallback for CJK text")
    }
}

// MARK: - Helper Extensions

private extension TextRenderingTests {
    
    /// Create SVG files for visual inspection during development
    func saveSVGForInspection(_ svg: SVG, name: String) {
        #if DEBUG
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                   in: .userDomainMask).first!
        let imageURL = documentsPath.appendingPathComponent("\(name).png")
        
        do {
            let imageData = try svg.pngData()
            try imageData.write(to: imageURL)
            print("Saved test image to: \(imageURL.path)")
        } catch {
            print("Failed to save test image: \(error)")
        }
        #endif
    }
}