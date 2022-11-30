# frozen_string_literal: true

class ForceStartService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  def call
    return "Сейчас нет документов в ожидании" unless document

    DividerService.new.divide_document(document)
    nil
  end

  private

  def message
    params[:message]
  end

  def chat
    @chat ||= Chat.find_by id: message.chat.id
  end

  def document
    @document ||= chat&.documents&.pending&.last
  end
end
