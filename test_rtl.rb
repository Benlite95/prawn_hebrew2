require_relative 'lib/prawn_hebrew'

Prawn::Document.generate("test_rtl.pdf") do
  font_families.update("GveretLevinHebrew" => {
    normal: "C:/Windows/Fonts/Arial.ttf"
  })
  
  hebrew_text = "כיכר השבת - אתר החדשות החרדי הגדול בישראל. כאן תמצאו חדשות, עדכונים, חדשות חרדים, תרבות, תמונות, וידאו, חדשות המוזיקה ,hello there שיעורי תורה, אוכל כשר, יהדות ועוד"
  
  # Test 1: Single line in wide box
  text_box "Test 1: Wide box (should fit on fewer lines)", at: [10, 700], width: 500
  hebrew_text_box hebrew_text, at: [10, 680], width: 500, height: 200, size: 12
  
  # Test 2: Narrow box (will cause wrapping)
  text_box "Test 2: Narrow box (will wrap to multiple lines)", at: [10, 450], width: 500
  hebrew_text_box hebrew_text, at: [10, 430], width: 200, height: 300, size: 12
  
  # Test 3: With explicit newlines
  multiline_text = "שורה ראשונה\nשורה שנייה\nשורה שלישית"
  text_box "Test 3: Explicit newlines", at: [10, 100], width: 500
  hebrew_text_box multiline_text, at: [10, 80], width: 300, height: 100, size: 12
end

puts "PDF generated: test_rtl.pdf"
