#!/usr/bin/env ruby
require 'prawn'
require_relative 'lib/prawn_hebrew'

# Note: prawn-table gem needs to be installed separately for table support
# For now, test the existing hebrew_text_box functionality

puts "Testing PrawnHebrew functionality..."

# Test 1: Hebrew text box with Hebrew content
puts "\nTest 1: Creating Hebrew text box with mixed content..."
begin
  Prawn::Document.generate("test_hebrew_text_mixed.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    text "Hebrew Text Box Test", size: 18, style: :bold
    move_down 10
    
    hebrew_text_box "שלום עולם! This is mixed Hebrew and English text in a text box.",
      at: [50, 700],
      width: 500,
      height: 100
  end
  puts "✓ Test 1 passed: test_hebrew_text_mixed.pdf created"
rescue => e
  puts "✗ Test 1 failed: #{e.message}"
end

# Test 2: Multiple Hebrew text boxes
puts "\nTest 2: Creating document with multiple Hebrew sections..."
begin
  Prawn::Document.generate("test_hebrew_sections.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    font("GveretLevinHebrew") do
      text "Hebrew Document", size: 18
      move_down 20
      
      text "Section 1: שם הפרק", size: 14
      move_down 10
    end
    
    hebrew_text_box "זהו הסבר בעברית על הפרק הראשון. English text can be mixed freely.",
      at: [50, 650],
      width: 500,
      height: 80
    
    move_down 100
    
    font("GveretLevinHebrew") do
      text "Section 2: חלק שני", size: 14
      move_down 10
    end
    
    hebrew_text_box "חלק שני של המסמך עם עברית וEnglish.",
      at: [50, 500],
      width: 500,
      height: 80
  end
  puts "✓ Test 2 passed: test_hebrew_sections.pdf created"
rescue => e
  puts "✗ Test 2 failed: #{e.message}"
end

# Test 3: Hebrew formatted text method
puts "\nTest 3: Testing hebrew_formatted_text method..."
begin
  Prawn::Document.generate("test_formatted_fragments.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    text "Hebrew Formatted Text", size: 18, style: :bold
    move_down 10
    
    fragments = hebrew_formatted_text("שלום world שלוום עם עברית",
      size: 12,
      style: :normal)
    
    formatted_text(fragments)
  end
  puts "✓ Test 3 passed: test_formatted_fragments.pdf created"
rescue => e
  puts "✗ Test 3 failed: #{e.message}"
end

# Test 4: Shrink to fit functionality
puts "\nTest 4: Testing shrink_to_fit with Hebrew text..."
begin
  Prawn::Document.generate("test_shrink_hebrew.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    text "Shrink to Fit Test", size: 18, style: :bold
    move_down 10
    
    long_hebrew_text = "זהו טקסט ארוך מאוד בעברית שצריך להיות מוקטן כדי שיתאים לתוך הקופסה המוגדרת. This is a long text that needs to shrink."
    
    hebrew_text_box long_hebrew_text,
      at: [50, 600],
      width: 300,
      height: 100,
      overflow: :shrink_to_fit
  end
  puts "✓ Test 4 passed: test_shrink_hebrew.pdf created"
rescue => e
  puts "✗ Test 4 failed: #{e.message}"
end

puts "\n✅ Core functionality tests completed!"

# Test 5: Hebrew text with punctuation
puts "\nTest 5: Testing Hebrew text with trailing punctuation..."
begin
  Prawn::Document.generate("test_hebrew_punctuation.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    text "Hebrew Punctuation Test", size: 18, style: :bold
    move_down 20
    
    # Test various punctuation cases
    test_cases = [
      "שלום.",
      "שלום עולם.",
      "שלום, עולם!",
      "מה שלומך?",
      "Hello שלום.",
      "שלום world.",
      "שלום: עולם",
      "Test: שלום עולם."
    ]
    
    test_cases.each do |test_text|
      font("GveretLevinHebrew") do
        text "Input: #{test_text}", size: 10
      end
      move_down 5
      
      hebrew_text_box test_text,
        at: [50, cursor],
        width: 400,
        height: 30,
        size: 14
      
      move_down 40
    end
  end
  puts "✓ Test 5 passed: test_hebrew_punctuation.pdf created"
rescue => e
  puts "✗ Test 5 failed: #{e.message}"
end

puts "\nNote: For table support, please install prawn-table gem:"
puts "  gem install prawn-table"

# Test 6: Sanitization of problematic characters
puts "\nTest 6: Testing sanitization of problematic characters..."
begin
  Prawn::Document.generate("test_sanitization.pdf") do
    # Register Hebrew font
    font_families.update(
      "GveretLevinHebrew" => {
        normal: "C:/Windows/Fonts/david.ttf"
      }
    )
    
    text "Sanitization Test", size: 18, style: :bold
    move_down 20
    
    # Test various problematic characters
    test_cases = [
      "Text with em\u2014dash",               # em dash
      "Text with en\u2013dash",               # en dash  
      "Hello\u00A0World",                     # non-breaking space
      "Smart \u201Cquotes\u201D test",        # smart quotes
      "Ellipsis\u2026 test",                  # ellipsis
      "Arrow \u2192 test",                    # arrow
      "Bullet \u2022 point",                  # bullet
      "Mixed: hello\u2014world\u2026",        # mixed with problematic chars (English only)
      "Test\u2028line",                       # line separator
    ]
    
    test_cases.each_with_index do |test_text, idx|
      text "Test #{idx + 1}:", size: 10
      move_down 5
      
      hebrew_text_box test_text,
        at: [50, cursor],
        width: 400,
        height: 30,
        size: 12
      
      move_down 40
    end
    
    # Hebrew-specific tests with Hebrew font
    move_down 20
    font("GveretLevinHebrew") do
      text "Hebrew sanitization tests:", size: 12
    end
    move_down 10
    
    hebrew_cases = [
      "שלום\u200Bעולם",                       # zero-width space in Hebrew
      "שלום\u2014עולם",                        # em dash in Hebrew
    ]
    
    hebrew_cases.each_with_index do |test_text, idx|
      hebrew_text_box test_text,
        at: [50, cursor],
        width: 400,
        height: 30,
        size: 12
      
      move_down 40
    end
  end
  puts "✓ Test 6 passed: test_sanitization.pdf created"
rescue => e
  puts "✗ Test 6 failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts "\nGenerated PDF files:"
puts "  - test_hebrew_text_mixed.pdf"
puts "  - test_hebrew_sections.pdf"
puts "  - test_formatted_fragments.pdf"
puts "  - test_shrink_hebrew.pdf"

