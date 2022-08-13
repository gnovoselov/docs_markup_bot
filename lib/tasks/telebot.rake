# frozen_string_literal: true

require 'telegram/bot'

namespace :telebot do
  task run: [ :environment ] do
    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      bot.listen do |message|
        IncomingMessageService.perform(bot: bot, message: message)
      end
    end
  end
end
