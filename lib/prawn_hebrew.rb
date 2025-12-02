require 'prawn'
require_relative 'version'

module PrawnHebrew
  module Text
    DEFAULT_HEBREW_FONT = 'GveretLevinHebrew'.freeze
    DEFAULT_ENGLISH_FONT = 'Helvetica'.freeze
    
    # Set to true for debugging which text rendering path is used
    DEBUG_MODE = false
    INVISIBLE_CHARS = /[\u2011\u2010\u2012\u2013\u2014\u2018\u2019\u201C\u201D\u2026\u200B\u200C\u200D\u200E\u200F\uFEFF\u00AD\u202A\u202B\u202C\u202D\u202E]/.freeze
    NBSP_CHARS = /[\u00A0\u202F]/.freeze




    def sanitize_text(text)
      return text if text.nil?
      text.to_s.gsub(INVISIBLE_CHARS, ' ').gsub(NBSP_CHARS, ' ')
    end

    def hebrew_formatted_text(text, size: 12, style: :normal, hebrew_font: DEFAULT_HEBREW_FONT, english_font: DEFAULT_ENGLISH_FONT)
      text = sanitize_text(text)
      
      # Split by newlines first to process each line independently
      lines = text.to_s.split("\n")
      all_fragments = []
      
      styles = style.is_a?(Array) ? style : [style].compact
      
      lines.each_with_index do |line, line_idx|
        words = line.split(/(\s+)/)
        hebrew_run = []
        
        words.each do |word|
          if word.strip.empty?
            all_fragments << { text: word, font: english_font, size: size, styles: styles } if word != ' '
            next
          end

          if word =~ /\p{Hebrew}/
            hebrew_run << word
          else
            unless hebrew_run.empty?
              hebrew_run.reverse.each_with_index do |hw, idx|
                all_fragments << { text: hw, font: hebrew_font, size: size, direction: :rtl, styles: styles }
                all_fragments << { text: ' ', font: hebrew_font, size: size, direction: :rtl, styles: styles } if idx < hebrew_run.length - 1
              end
              all_fragments << { text: ' ' }
              hebrew_run.clear
            end
            all_fragments << { text: "#{word} ", font: english_font, size: size, styles: styles }
          end
        end

        unless hebrew_run.empty?
          hebrew_run.reverse.each_with_index do |hw, idx|
            all_fragments << { text: hw, font: hebrew_font, size: size, direction: :rtl, styles: styles }
            all_fragments << { text: ' ', font: hebrew_font, size: size, direction: :rtl, styles: styles } if idx < hebrew_run.length - 1
          end
        end
        
        # Add newline between lines (except after the last line)
        if line_idx < lines.length - 1
          all_fragments << { text: "\n", font: english_font, size: size, styles: styles }
        end
      end
      
      all_fragments
    end

    def hebrew_text_box(text, size: 12, style: :normal,
                        hebrew_font: DEFAULT_HEBREW_FONT,
                        english_font: DEFAULT_ENGLISH_FONT,
                        direction: :auto, **box_opts)
      
      # Handle font specification in box_opts or use defaults
      final_hebrew_font = box_opts.delete(:hebrew_font) || hebrew_font
      final_english_font = box_opts.delete(:english_font) || english_font
      final_size = box_opts.delete(:size) || size
      rotation = box_opts.delete(:rotate) || 0
      char_spacing = box_opts.delete(:character_spacing) || 0
      leading = box_opts.delete(:leading) || 0
      min_font_size = box_opts.delete(:min_font_size)
      overflow = box_opts[:overflow]
      
      # Check if text contains Hebrew characters
      contains_hebrew = text.to_s =~ /\p{Hebrew}/
      
      # If direction is auto, determine based on content
      if direction == :auto
        direction = contains_hebrew ? :rtl : :ltr
      end
      
      # Handle shrink_to_fit behavior
      if overflow == :shrink_to_fit
        box_opts.delete(:overflow)
        
        if !contains_hebrew && direction == :ltr
          # English-only: use Prawn's built-in shrink_to_fit
          box_opts[:overflow] = :shrink_to_fit
          box_opts[:min_font_size] = min_font_size if min_font_size
          render_english_only_text(text, final_size, style, final_english_font, 
                                   rotation, char_spacing, leading, box_opts)
        else
          # Hebrew/mixed: implement shrinking manually
          shrink_hebrew_text_to_fit(text, final_size, style, final_hebrew_font, 
                                    final_english_font, char_spacing, leading, 
                                    min_font_size, rotation, box_opts)
        end
      else
        # Normal rendering without shrinking
        if !contains_hebrew && direction == :ltr
          render_english_only_text(text, final_size, style, final_english_font, 
                                   rotation, char_spacing, leading, box_opts)
        else
          # For Hebrew text or RTL direction, use formatted text approach
          if rotation != 0
            rotate(rotation, origin: box_opts[:at] || [0, 0]) do
              render_hebrew_text_content(text, contains_hebrew, direction, final_size, style, 
                                 final_hebrew_font, final_english_font, char_spacing, leading, box_opts)
            end
          else
            render_hebrew_text_content(text, contains_hebrew, direction, final_size, style, 
                               final_hebrew_font, final_english_font, char_spacing, leading, box_opts)
          end
        end
      end
    end
    
    private
    
    # Render pure English text using standard Prawn text_box for optimal performance
    def render_english_only_text(text, final_size, style, final_english_font, 
                                 rotation, char_spacing, leading, box_opts)
          font(final_english_font) do
            text_box(text.to_s, { size: final_size, style: style }.merge(box_opts))
          end
    end
    
    # Render Hebrew text or mixed text using formatted text approach
    def render_hebrew_text_content(text, contains_hebrew, direction, final_size, style, 
                           final_hebrew_font, final_english_font, char_spacing, leading, box_opts)
      # Apply character spacing and leading if specified
      character_spacing(char_spacing) do
        fragments = hebrew_formatted_text(text, size: final_size, style: style,
                                          hebrew_font: final_hebrew_font,
                                          english_font: final_english_font)
        
        # Add leading to box_opts if specified
        box_opts[:leading] = leading if leading > 0
        
        # Don't set direction or alignment - let the reversed fragments handle it
        formatted_text_box(fragments, box_opts)
      end
    end
    
    # Shrink Hebrew text to fit in the box by reducing font size
    def shrink_hebrew_text_to_fit(text, initial_size, style, hebrew_font, english_font, 
                                   char_spacing, leading, min_font_size, rotation, box_opts)
      min_size = min_font_size || 5
      
      # Get box dimensions
      box_width = box_opts[:width]
      box_height = box_opts[:height]
      
      return render_hebrew_text_content(text, true, :rtl, initial_size, style, 
                                       hebrew_font, english_font, char_spacing, leading, box_opts) unless box_width && box_height
      
      current_size = initial_size
      fitting_size = nil
      
      # Try progressively smaller sizes
      while current_size >= min_size
        # Calculate approximate text dimensions at this size
        test_fragments = hebrew_formatted_text(text, size: current_size, style: style,
                                               hebrew_font: hebrew_font,
                                               english_font: english_font)
        
        # Calculate total text width by measuring each fragment
        total_width = 0
        total_height = current_size * 1.2 # Approximate line height
        
        test_fragments.each do |fragment|
          next if fragment[:text] == "\n"
          fragment_font = fragment[:font] || hebrew_font
          font(fragment_font) do
            total_width += width_of(fragment[:text], size: current_size)
          end
        end
        
        # Count newlines to estimate height
        line_count = text.count("\n") + 1
        total_height = (current_size * 1.2 * line_count) + (leading * (line_count - 1))
        
        # Check if it would fit (with some padding)
        if total_width <= (box_width * 0.95) && total_height <= (box_height * 0.95)
          fitting_size = current_size
          break
        end
        
        current_size -= 0.5
      end
      
      # Use the fitting size, or min_size if nothing fit
      final_size = fitting_size || min_size
      
      # Render with the final size
      fragments = hebrew_formatted_text(text, size: final_size, style: style,
                                        hebrew_font: hebrew_font,
                                        english_font: english_font)
      
      render_opts = box_opts.dup
      render_opts[:leading] = leading if leading > 0
      
      character_spacing(char_spacing) do
        if rotation != 0
          rotate(rotation, origin: render_opts[:at] || [0, 0]) do
            formatted_text_box(fragments, render_opts)
          end
        else
          formatted_text_box(fragments, render_opts)
        end
      end
    end
  end
end

Prawn::Document.include PrawnHebrew::Text