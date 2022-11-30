# frozen_string_literal: true

class ClearService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID

  include DocumentsApiConcern
  include BackgroundsConcern
  include WipConcern

  def call
    dept = 0
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        structural_element.paragraph.elements.each do |element|
          next unless element.text_run.present?

          requests << update_background(element, :text_run, 0, -1 * dept)

          next if element.text_run.content.blank?

          next if element.text_run&.content == DUPLICATED_LINK_CAPTION

          if WIP_OTHERS.match?(remove_non_ascii(element.text_run&.content))
            requests << remove_range(element.start_index - dept, element.end_index - dept)
            dept += element.end_index - element.start_index
          end
        end
      end
    end

    "Документ очищен от меток"
  end
end
