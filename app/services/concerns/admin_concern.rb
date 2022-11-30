# frozen_string_literal: true

module AdminConcern
  extend ActiveSupport::Concern

  def is_admin?(participant)
    TELEGRAM_ADMINS.include?(participant&.username)
  end
end
