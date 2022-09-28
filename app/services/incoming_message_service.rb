# frozen_string_literal: true

class IncomingMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - bot: [Telegram::Bot] Bot instance
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern

  INVALID_COMMAND_FORMAT = "Неверный формат команды. Инструкцию можно вызвать командой /start".freeze
  ERROR_MESSAGE = "Возникла ошибка или документ не найден. Попробуйте еще раз или нажмите /start".freeze
  ALGORITHM_MESSAGE = "Кирилл присылает ссылку на документ, начиная свое сообщение командой /process, вот так:\n `/process https://docs.google.com/document/d/....`\n\nБот присылает в чат приветственное сообщение и приглашение к ответу. Мы все в течение 15 минут отвечаем на его сообщение командой. Вот так (со слешем вначале):\n\n/in\n\nПосле 15 минут бот подсчитает, количество желающих, разделит текст и скажет об этом.\n\nКогда перевели, пишем:\n\n/finish\n\nКогда все куски готовы, бот уберет метки и фон и отправит сообщение Кириллу.\n\nНаш глоссарий и правила, которыми мы руководствуемся при переводе, находятся по адресу https://docs.google.com/spreadsheets/d/1SMHIkMDnIbtmJMNrvxk6lMGMkG81IiVk48mJzG3VnGQ/edit?usp=sharing \n(там надо потыкать по вкладочкам). \nМы вносим туда часто встречающиеся термины, которые надо обычно перепроверять через википедию или переводить с использованием чего-то специального типа постановления правительства о транслитерации, а также вещи, которые переводятся по разному, но с которыми нам надо соблюдать единообразие.".freeze

  def call
    Array(process_incoming_message).each do |text|
      next if text.blank?
      send_message(bot, message, text)
    end
  rescue StandardError => error
    Rails.logger.info error
  end

  private

  def process_incoming_message
    return unless message.respond_to?(:text)

    case message.text
    when '/start'
      TELEBOT_HELP_MESSAGE
    when '/help'
      ALGORITHM_MESSAGE
    when /^\/divide[\t\s\r\n]+([^\s]+)[\t\s\r\n]+([^\s]+)/
      FormatService.perform(document_id: get_document_id($1), parts: $2.to_i)
    when /^\/divide[\t\s\r\n]+([^\s]+)/
      FormatService.perform(document_id: get_document_id($1))
    when /^\/clear[\t\s\r\n]+([^\s]+)/
      ClearService.perform(document_id: get_document_id($1))
    when /^\/process[\t\s\r\n]+([^\s]+)/
      StartMessageService.perform(chat_id: message.chat.id, document_id: get_document_id($1))
    when /^\/restart[\t\s\r\n]+([^\s]+)/
      RestartDocumentService.perform(chat_id: message.chat.id, document_id: get_document_id($1))
    when /^\/finish(@DocsDividerBot)?/
      FinishService.perform(message: message)
    when /^\/in(@DocsDividerBot)?[\t\s\r\n]*([^\s]+)?/
      AddParticipantService.perform(message: message, parts: $2)
    when /^\/share[\t\s\r\n]*([^\s]+)?/
      ShareService.perform(message: message, part: $1)
    when /^\/take(@DocsDividerBot)?/
      TakeService.perform(message: message)
    when /^\/wait[\t\s\r\n]*([^\s]+)?/
      WaitService.perform(message: message, parts: $1)
    when /^\/out$/
      RemoveParticipantService.perform(message: message)
    when /^\/divide/, /^\/clear/, /^\/process/
      INVALID_COMMAND_FORMAT
    end
  rescue StandardError => error
    Rails.logger.info error
    Rails.logger.info error.backtrace.join("\n")
    ERROR_MESSAGE
  end

  def send_message(bot, message, text)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  def message
    params[:message]
  end

  def bot
    params[:bot]
  end
end
