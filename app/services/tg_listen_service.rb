# frozen_string_literal: true

class TgListenService < ApplicationService
  def call
    attempts ||= 0
    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      bot.listen do |message|
        IncomingMessageService.perform(bot: bot, message: message)
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if (attempts += 1) > 5
      message = "Restarting service because of an error"
      notify_support_and_log_error(e, message)
      `service run_telebot restart`
      exit
    else
      notify_support_and_log_error(e)
      sleep 5
      retry
    end
  rescue StandardError => error
    notify_support_and_log_error(error)
  end
end
