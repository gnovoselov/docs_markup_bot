# frozen_string_literal: true

class LinksService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    dept = 0
    urls = {}
    change_document(params[:document_id]) do |document, structural_element, requests|
      structural_element.paragraph&.elements&.each do |element|
        next if element&.text_run&.content.blank?

        url = element&.text_run&.text_style&.link&.url
        next if url.blank?

        original_link_props = urls[url]
        if original_link_props.blank?
          urls[url] = {
            start_index: element.start_index,
            marked: false
          }
        else
          unless original_link_props[:marked]
            new_requests, additional_dept = add_link_caption(original_link_props[:start_index], DUPLICATED_LINK_CAPTION, dept)
            new_requests.each { |req| requests << req }
            dept += additional_dept
            urls[url][:marked] = true
          end

          new_requests, additional_dept = add_link_caption(element.start_index, LINK_DUPLICATE_CAPTION, dept)
          new_requests.each { |req| requests << req }
          dept += additional_dept
        end
      end
    end

    dept > 0 ? 'Внимание! В документе найдены продублированные ссылки.' : 'Дублированных ссылок не найдено.'
  end

  private

  def add_link_caption(index, caption, dept)
    text_style = {
      background_color: create_color(1, 0, 0),
      foreground_color: create_color(1, 1, 1),
      bold: true
    }

    start_index = index + dept
    [
      [
        insert_text_before(start_index, caption),
        update_text_style(start_index, start_index + caption.size, text_style)
      ],
      caption.size
    ]
  end
end
