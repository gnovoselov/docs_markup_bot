# frozen_string_literal: true

require "google/apis/docs_v1"

module DocsAdapterConcern
  extend ActiveSupport::Concern

  include AuthorizationConcern

  APPLICATION_NAME = "Markup Bot".freeze

  private

  def docs_adapter
    @docs_adapter ||= load_docs_adapter
  end

  def load_docs_adapter
    service = Google::Apis::DocsV1::DocsService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service
  end
end
