# frozen_string_literal: true

require "google/apis/docs_v1"

module DocumentsApiConcern
  extend ActiveSupport::Concern

  include DocsAdapterConcern

  private

  def change_document(document_id)
    document = docs_adapter.get_document document_id

    document.body.content.each do |structural_element|
      yield(document, structural_element, request.requests)
    end

    docs_adapter.batch_update_document(document.document_id, request)
  end

  def request
    @request ||= Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: [])
  end
end
