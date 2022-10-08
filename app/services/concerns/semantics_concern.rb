# frozen_string_literal: true

require "google/apis/docs_v1"

module SemanticsConcern
  extend ActiveSupport::Concern

  include AuthorizationConcern

  JOY_EXPRESSIONS = %w(Супер Здорово Отлично Прекрасно Замечательно Красота Шикарно)

  private

  def parts_caption(count)
    count = count.to_i
    count == 1 ? 'часть' : (count > 4 ? 'частей' : 'части')
  end

  def express_joy
    JOY_EXPRESSIONS.sample
  end
end
