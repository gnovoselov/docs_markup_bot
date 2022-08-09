# frozen_string_literal: true

require 'telegram/bot'

TELEBOT_CONFIG = YAML::load_file(Rails.root.join('config', 'telebot.yml'))
TELEBOT_HELP_MESSAGE = File.read(Rails.root.join('README.md'))

namespace :telebot do
  task run: [ :environment ] do
    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      bot.listen do |message|
        IncomingMessageService.perform(bot: bot, message: message)
      end
    end
  end
end
