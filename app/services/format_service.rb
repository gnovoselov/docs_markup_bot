# frozen_string_literal: true

class FormatService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - parts: [Integer] Number of parts to divide the document into (by default every part consists of 1300 symbols)

  include DocumentsApiConcern
  include BackgroundsConcern

  DEFAULT_CHUNK_SIZE = 1200

  def call
    color_index = 1 # skipping white background
    last_index = 0
    finish_index = nil
    chunk_size = nil
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        finish_index ||= document.body.content.last.end_index
        chunk_size ||= params[:parts] ? (finish_index / params[:parts]).round : DEFAULT_CHUNK_SIZE

        if (structural_element.end_index - last_index >= chunk_size * 0.9) && (finish_index - structural_element.end_index > chunk_size * 0.35)
          color_index += 1
          last_index = structural_element.end_index
        end

        structural_element.paragraph.elements.each do |element|
          # requests << update_background(element.inline_object_element, color_index) if element.inline_object_element.present?
          requests << update_background(element, :text_run, color_index) if element.text_run.present?
        end
      end
    end
  end
end
