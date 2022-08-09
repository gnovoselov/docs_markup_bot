# frozen_string_literal: true

require 'concerns/authorization_concern'
require 'concerns/backgrounds_concern'
require 'concerns/docs_adapter_concern'
require 'concerns/documents_api_concern'

class ApplicationService
  def self.perform(params = {}, &block)
    new(params).call(&block)
  end

  def initialize(params = {})
    @params = params
  end

  def call; end

  private

  attr_reader :params

  def serialized_params
    params.to_json
  end
end
