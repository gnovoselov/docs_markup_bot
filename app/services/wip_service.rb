# frozen_string_literal: true

class WipService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - part: [Integer] Chunk index
  # - username: [String] User name

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    chunk_index = 0
    colors = []
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        structural_element.paragraph.elements.each do |element|
          next if element&.text_run&.content&.blank? || chunk_caption?(element)

          bg = element.text_run.text_style.background_color
          if bg
            rgb = bg.color.rgb_color
            color = [rgb.red, rgb.green, rgb.blue]
            unless colors.include?(color)
              chunk_index += 1
              colors << color

              if chunk_index == params[:part]
                update_text(element, requests)
              end
            end
          end
        end
      end
    end

    'Done'
  end

  private

  def update_text(element, requests)
    create_chunk_mark(element).each do |request|
      requests << request
    end
  end

  def create_chunk_mark(element)
    caption = get_wip_text(params[:username])
    text_style = {
      background_color: create_color(0, 0, 0),
      foreground_color: create_color(1, 1, 1),
      bold: true
    }

    [
      insert_text_before(element, caption),
      update_text_style(element.start_index, element.start_index + caption.size, text_style)
    ]
  end

  def chunk_caption?(element)
    element.text_run.content.match?(WIP_OTHERS)
  end
end
