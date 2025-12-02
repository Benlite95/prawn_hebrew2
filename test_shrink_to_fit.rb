require 'prawn'
require_relative 'lib/prawn_hebrew'

# Create a PDF to test shrink_to_fit functionality
Prawn::Document.generate("test_shrink_to_fit.pdf") do
  # Register Hebrew font - using David which is a standard Windows Hebrew font
  font_families.update(
    "GveretLevinHebrew" => {
      normal: "C:/Windows/Fonts/david.ttf"
    }
  )
  
  # Test 1: Hebrew text that's too long - should shrink
  text "Test 1: Long Hebrew text with shrink_to_fit", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 50
  hebrew_text_box(
    "טקסט ארוך מאוד בעברית שצריך להתכווץ כדי להיכנס לתוך התיבה הקטנה הזאת",
    at: [50, cursor],
    width: 200,
    height: 50,
    size: 14,
    overflow: :shrink_to_fit,
    min_font_size: 6
  )
  
  move_down 70
  
  # Test 2: Short Hebrew text - should NOT shrink
  text "Test 2: Short Hebrew text (no shrinking needed)", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 50
  hebrew_text_box(
    "טקסט קצר",
    at: [50, cursor],
    width: 200,
    height: 50,
    size: 14,
    overflow: :shrink_to_fit,
    min_font_size: 6
  )
  
  move_down 70
  
  # Test 3: Mixed Hebrew and English with shrink
  text "Test 3: Mixed Hebrew/English with shrink_to_fit", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 50
  hebrew_text_box(
    "Hello שלום World עולם this is a very long mixed text that needs to shrink",
    at: [50, cursor],
    width: 200,
    height: 50,
    size: 14,
    overflow: :shrink_to_fit,
    min_font_size: 6
  )
  
  move_down 70
  
  # Test 4: Multiple lines with shrink
  text "Test 4: Multi-line Hebrew with shrink_to_fit", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 80
  hebrew_text_box(
    "שורה ראשונה ארוכה מאוד\nשורה שנייה גם ארוכה\nשורה שלישית עם הרבה טקסט",
    at: [50, cursor],
    width: 200,
    height: 80,
    size: 14,
    overflow: :shrink_to_fit,
    min_font_size: 6,
    leading: 2
  )
  
  move_down 100
  
  # Test 5: Without shrink_to_fit (for comparison)
  text "Test 5: Long text WITHOUT shrink_to_fit (will overflow)", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 50
  hebrew_text_box(
    "טקסט ארוך מאוד בעברית שלא יתכווץ ויצא מהתיבה",
    at: [50, cursor],
    width: 200,
    height: 50,
    size: 14,
    overflow: :truncate
  )
  
  move_down 70
  
  # Test 6: English text with shrink (using Prawn's native)
  text "Test 6: English text with shrink_to_fit", size: 14, style: :bold
  move_down 10
  
  stroke_rectangle [50, cursor], 200, 50
  hebrew_text_box(
    "This is a very long English text that should shrink to fit inside the box",
    at: [50, cursor],
    width: 200,
    height: 50,
    size: 14,
    overflow: :shrink_to_fit,
    min_font_size: 6
  )
end

puts "PDF created: test_shrink_to_fit.pdf"
puts "Open it to verify shrink_to_fit is working correctly."
puts ""
puts "Expected results:"
puts "  Test 1: Hebrew text should be smaller to fit"
puts "  Test 2: Hebrew text should remain at original size (14pt)"
puts "  Test 3: Mixed text should shrink"
puts "  Test 4: Multi-line should shrink with proper spacing"
puts "  Test 5: Text should be truncated/overflow"
puts "  Test 6: English text should shrink"
