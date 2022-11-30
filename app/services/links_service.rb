# frozen_string_literal: true

class LinksService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    caption = DUPLICATED_LINK_CAPTION
    dept = 0
    urls = []
    change_document(params[:document_id]) do |document, structural_element, requests|
      structural_element.paragraph&.elements&.each do |element|
        next if element&.text_run&.content.blank?

        url = element&.text_run&.text_style&.link&.url
        next if url.blank?

        if urls.include?(url)
          text_style = {
            background_color: create_color(1, 0, 0),
            foreground_color: create_color(1, 1, 1),
            bold: true
          }
          start_index = element.start_index + dept
          requests << insert_text_before(start_index, caption)
          requests << update_text_style(start_index, start_index + caption.size, text_style)
          dept += caption.size
        else
          urls << url
        end
      end
    end

    dept > 0 ? 'Внимание! В документе найдены продублированные ссылки.' : 'Дублированных ссылок не найдено.'
  end
end
