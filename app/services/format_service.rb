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

        structural_element.paragraph.elements.each do |element|
          # puts element.text_run.content
          requests << update_background(element, :text_run, color_index) if element.text_run.present?
        end

        # puts "Chunk size: #{chunk_size}"
        # puts "Part chunk: #{chunk_size * 0.35}"
        # puts "Current chunk: #{structural_element.end_index - last_index}"
        # puts "Next chunk: #{finish_index - structural_element.end_index}"

        if (structural_element.end_index - last_index >= chunk_size * 0.9) && (finish_index - structural_element.end_index > chunk_size * 0.35)
          # puts "[SWITCH]"
          color_index += 1
          last_index = structural_element.end_index
        end
        # puts "----------------------------"
      end
    end

    "Done"
  end
end
