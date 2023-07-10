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
    if (attempts += 1) > MAX_ATTEMPTS
      message = "Notification has failed to be sent (attempt #{attempts}): #{notification.inspect}"
      log_error(e, message)
    else
      sleep 5
      retry
    end
  end

  def notifications
    params[:notifications] || []
  end
end
