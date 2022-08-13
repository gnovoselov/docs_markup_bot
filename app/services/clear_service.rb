# frozen_string_literal: true

class ClearService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID

  include DocumentsApiConcern
  include BackgroundsConcern

  def call
    change_document(params[:document_id]) do |document, structural_element, requests|
      process_structural_element(document, structural_element, requests)
    end

    "Документ очищен от меток"
  end

  private

  def process_structural_element(_document, structural_element, requests)
    return unless structural_element.paragraph

    structural_element.paragraph.elements.each do |element|
      # requests << update_background(element.inline_object_element) if element.inline_object_element.present?
      requests << update_background(element, :text_run) if element.text_run.present?
    end
  end
end
