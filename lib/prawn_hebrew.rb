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
      
      # Check if text contains Hebrew characters
      contains_hebrew = text.to_s =~ /\p{Hebrew}/
      
      # If direction is auto, determine based on content
      if direction == :auto
        direction = contains_hebrew ? :rtl : :ltr
      end
      
      # For completely English text (no Hebrew characters and LTR direction), 
      # use standard Prawn text_box for better performance and compatibility
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
  end
end

Prawn::Document.include PrawnHebrew::Text