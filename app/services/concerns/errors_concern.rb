# frozen_string_literal: true

require "google/apis/docs_v1"

module ErrorsConcern
  extend ActiveSupport::Concern

  private

  def notify_support_and_log_error(error)
    NotificationsService.perform(notifications: [{
      chat_id: TELEGRAM_SUPPORT_CHAT,
      text: "!!!FAILURE!!!\n#{error}"
    }])

    `service run_telebot stop`
    `service run_telebot start`

    Rails.logger.error error
    Rails.logger.info error.backtrace.join("\n")
  end
end
