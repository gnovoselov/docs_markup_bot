# frozen_string_literal: true

class WipRemoveService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - username: [String] User name

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    wip_text = get_wip_text(params[:username])
    dept = 0
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        structural_element.paragraph.elements.each do |element|
          next if element&.text_run&.content&.blank?

          if element.text_run.content == wip_text
            requests << remove_range(element.start_index - dept, element.end_index - dept)
            dept += wip_text.length
          end
        end
      end
    end
  end
end
