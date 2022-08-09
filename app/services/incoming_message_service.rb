# frozen_string_literal: true

class IncomingMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - bot: [Telegram::Bot] Bot instance
  # - message: [Telegram::Message] Incoming message

  ERROR_MESSAGE = "Something went wrong or the document was not found. Please try again or use /start".freeze

  def call
    case message.text
    when '/start'
      send_message(bot, message, TELEBOT_HELP_MESSAGE)
    when /^\/divide ([^\s]+) ([^\s]+)/
      FormatService.perform(document_id: get_document_id($1), parts: $2.to_i)
      send_message(bot, message, "Done")
    when /^\/divide ([^\s]+)/
      FormatService.perform(document_id: get_document_id($1))
      send_message(bot, message, "Done")
    when /^\/clear ([^\s]+)/
      ClearService.perform(document_id: get_document_id($1))
      send_message(bot, message, "Cleared")
    end
  rescue StandardError => error
    Rails.logger.info error
    send_message(bot, message, ERROR_MESSAGE)
  end

  private

  def send_message(bot, message, text)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  def get_document_id(url)
    matches = url.match(/^https:\/\/docs.google.com\/document\/d\/([^\/]+)/)
    return '' unless matches

    matches[1]
  end

  def message; params[:message]; end

  def bot; params[:bot]; end
end
