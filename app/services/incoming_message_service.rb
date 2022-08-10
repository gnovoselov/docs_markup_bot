# frozen_string_literal: true

class IncomingMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - bot: [Telegram::Bot] Bot instance
  # - message: [Telegram::Message] Incoming message

  INVALID_COMMAND_FORMAT = "Invalid command format. Please see manual /start".freeze
  ERROR_MESSAGE = "Something went wrong or the document was not found. Please try again or use /start".freeze

  def call
    send_message(bot, message, process_incoming_message)
  rescue StandardError => error
    Rails.logger.info error
  end

  private

  def process_incoming_message()
    case message.text
    when '/start'
      TELEBOT_HELP_MESSAGE
    when /^\/divide[\t\s\r\n]+([^\s]+)[\t\s\r\n]+([^\s]+)/
      result = FormatService.perform(document_id: get_document_id($1), parts: $2.to_i)
    when /^\/divide[\t\s\r\n]+([^\s]+)/
      FormatService.perform(document_id: get_document_id($1))
    when /^\/clear[\t\s\r\n]+([^\s]+)/
      ClearService.perform(document_id: get_document_id($1))
    when /^\/take[\t\s\r\n]+([^\s]+)[\t\s\r\n]+([^\s]+)/
      WipService.perform(document_id: get_document_id($1), part: $2.to_i, wip: true, user: message.from)
    when /^\/finish[\t\s\r\n]+([^\s]+)[\t\s\r\n]+([^\s]+)/
      WipService.perform(document_id: get_document_id($1), part: $2.to_i, user: message.from)
    when /^\/available[\t\s\r\n]+([^\s]+)/
      WipService.perform(document_id: get_document_id($1))
    when /^\/divide/
      INVALID_COMMAND_FORMAT
    when /^\/clear/
      INVALID_COMMAND_FORMAT
    when /^\/take/
      INVALID_COMMAND_FORMAT
    when /^\/finish/
      INVALID_COMMAND_FORMAT
    when /^\/available/
      INVALID_COMMAND_FORMAT
    end
  rescue StandardError => error
    Rails.logger.info error
    ERROR_MESSAGE
  end

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
