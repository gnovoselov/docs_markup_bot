# frozen_string_literal: true

class WipRemoveService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - username: [String] User name

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    request.requests << remove_text(get_wip_text(params[:username]))
    docs_adapter.batch_update_document(params[:document_id], request)
  end
end
