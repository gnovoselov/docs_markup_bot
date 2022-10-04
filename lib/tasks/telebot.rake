# frozen_string_literal: true

require 'telegram/bot'

namespace :telebot do
  task run: [ :environment ] do
    TgListenService.perform
  end
end
