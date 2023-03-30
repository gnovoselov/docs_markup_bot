# frozen_string_literal: true

require "google/apis/docs_v1"

module ErrorsConcern
  extend ActiveSupport::Concern

  private

  def notify_support_and_log_error(error, message = nil)
    Rails.logger.error(
      collect_errors([message, error.to_s, error.backtrace])
    )

    NotificationsService.perform(notifications: [{
      chat_id: TELEGRAM_SUPPORT_CHAT,
      text: collect_errors(['!!!FAILURE!!!', message, error])
    }])
  end

  def collect_errors(parts)
    parts.compact.join("\n")
  end
end
