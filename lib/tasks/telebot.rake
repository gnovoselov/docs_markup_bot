# frozen_string_literal: true

require 'telegram/bot'

namespace :telebot do
  task run: [ :environment ] do
    begin
      attempts ||= 0
      Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
        bot.listen do |message|
          IncomingMessageService.perform(bot: bot, message: message)
        end
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      raise e if (attempts += 1) > 5
      sleep 5
      retry
    rescue StandardError => error
      Rails.logger.error error
    end
  end
end
