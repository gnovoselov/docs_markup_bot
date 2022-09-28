# frozen_string_literal: true

require 'telegram/bot'

class NotificationsService < ApplicationService
  # @attr_reader params [Hash]
  # - notifications: [Array<Hash>] Notifications to be sent

  def call
    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      notifications.compact.uniq.each do |notification|
        bot.api.send_message(notification)
      end
    end
  end

  private

  def notifications
    params[:notifications] || []
  end
end
