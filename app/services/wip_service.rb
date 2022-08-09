# frozen_string_literal: true

class WipService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - part: [Integer] Chunk index
  # - wip: [Boolean] Is the chunk in progress
  # - user: [Telegram::User] User date consists of .first_name and .last_name

  include DocumentsApiConcern
  include TextConcern

  WIP = "WIP".freeze
  WIP_OTHERS = /^\s?\[#{WIP} ([^\]]+)\]/

  def call
    chunk_index = 0
    colors = []
    available_chunks = []
    username = params[:user] ? [params[:user].first_name, params[:user].last_name].compact.join(' ') : ''
    result = ''
    chunk_caption = nil
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        structural_element.paragraph.elements.each do |element|
          if chunk_caption?(element)
            chunk_caption = element
            next
          end

          bg = element.text_run.text_style.background_color
          if bg
            rgb = bg.color.rgb_color
            color = [rgb.red, rgb.green, rgb.blue]
            unless colors.include?(color)
              chunk_index += 1
              colors << color
              available_chunks << chunk_index if chunk_caption.nil?

              if chunk_index == params[:part]
                result = update_text(chunk_caption, element, username, requests)
              end

              chunk_caption = nil
            end
          end
        end
      end
    end

    result = "Chunk ##{params[:part]} was not found" if result.blank?
    params[:part] ? result : "Available numbers are: #{available_chunks.join(', ')}"
  end

  private

  def update_text(chunk_caption, element, username, requests)
    wip_self = /^\s?\[#{WIP} #{username}\]\s?/
    caption = chunk_caption&.text_run&.content || ''

    if params[:wip]
      if caption.match?(wip_self)
        return "This part is already taken by you"
      elsif matches = caption.match(WIP_OTHERS)
        return "This part is already taken by #{matches[1]}"
      else
        create_chunk_mark(element, username).each do |request|
          requests << request
        end
      end
    else
      if caption.match?(wip_self)
        requests << remove_element(chunk_caption)
      elsif matches = caption.match(WIP_OTHERS)
        return "You can not finish part taken by #{matches[1]}"
      else
        return "This part is not taken"
      end
    end

    "Done"
  end

  def create_chunk_mark(element, username)
    caption = " [#{WIP} #{username}] "
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
