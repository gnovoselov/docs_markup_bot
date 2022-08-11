# frozen_string_literal: true

class StartMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern

  MIN_CHUNK_LENGTH = 700

  def call
    return unless message && google_doc_link

    if document.persisted?
      return "Работа над документом завершена" if document.done?
      return "Документ уже в работе"
    end

    return "Этот документ пуст или недоступен!" if document_length == 0

    chat.inactivate_all!
    document.max_participants = document_length / MIN_CHUNK_LENGTH
    document.pending!

    "Друзья, у нас есть новый документ для перевода! \n\nКто участвует, нажмите, пожалуйста, /in"
  end

  private

  def message
    params[:message]
  end

  def document_length
    length = document_object.body.content.last.end_index
    length = MIN_CHUNK_LENGTH if length < MIN_CHUNK_LENGTH
    length
  end

  def document_object
    @document_object ||= get_document_object(document.document_id)
  end

  def chat
    @chat ||= Chat.find_or_create_by id: message.chat.id
  end

  def document
    @document ||= Document.find_or_initialize_by chat_id: chat.id, document_id: get_document_id(google_doc_link)
  end

  def google_doc_link
    @google_doc_link ||= message.entities.select do |e|
      e.type == 'text_link' && e.url.match?(GOOGLE_DOCS_URL)
    end.first&.url
  end
end
