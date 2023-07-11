# frozen_string_literal: true

require 'telegram/bot'

class NotificationsService < ApplicationService
  # @attr_reader params [Hash]
  # - notifications: [Array<Hash>] Notifications to be sent

  MAX_ATTEMPTS = 5

  def call
    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      notifications.compact.uniq.each do |notification|
        send_message(bot, notification)
      end
    end
  end

  private

  def send_message(bot, notification)
    attempts ||= 0
    bot.api.send_message(notification)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    error_code ||= SecureRandom.hex
    if (attempts += 1) > MAX_ATTEMPTS
      message = "[ERROR CODE #{error_code}] Notification has failed to be sent to #{notification[:chat_id]} (attempt #{attempts})"
      notify_support_and_log_error(e, message)
    else
      log_error(e, "#{message}: #{notification.inspect}")
      sleep 5
      retry
    end
  end

  def notifications
    params[:notifications] || []
  end
end
