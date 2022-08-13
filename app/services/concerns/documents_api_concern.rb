# frozen_string_literal: true

require "google/apis/docs_v1"

module DocumentsApiConcern
  extend ActiveSupport::Concern

  include DocsAdapterConcern

  GOOGLE_DOCS_URL = /^https:\/\/docs.google.com\/document\/d\/([^\/]+)/

  private

  def change_document(document_id)
    document = get_document_object(document_id)
    requests = []

    document.body.content.each do |structural_element|
      yield(document, structural_element, requests)
    end

    if requests.any?
      request.requests = requests
      docs_adapter.batch_update_document(document.document_id, request)
    end
  end

  def get_document_object(document_id)
    docs_adapter.get_document document_id
  end

  def get_document_id(url)
    matches = url.match(GOOGLE_DOCS_URL)
    return '' unless matches

    matches[1]
  end

  def request
    @request ||= Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: [])
  end
end
