# frozen_string_literal: true

class StartMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - chat_id: [Integer] Telegram chat ID
  # - document_id: [String] Google Docs ID

  include DocumentsApiConcern

  MIN_CHUNK_LENGTH = 700
  OPTIMAL_CHUNK_LENGTH = 1350
  APPROXIMATE_PAGE_LENGTH = 2300

  def call
    return unless chat_id && document_id

    if document.persisted?
      return "Работа над документом завершена" if document.done?
      return "Документ уже в работе"
    end

    length = document_length

    return "Этот документ пуст или недоступен!" if length == 0

    chat.inactivate_all!
    document.max_participants = length / MIN_CHUNK_LENGTH
    document.optimal_participants = length / OPTIMAL_CHUNK_LENGTH
    document.pending!

    "Друзья, у нас есть новый документ для перевода!\nСтраниц в нем примерно #{document_pages(length)}.\n\nКто участвует, нажмите, пожалуйста, /in\nПосле команды можно добавить количество кусочков, которые вы сегодня готовы перевести, если их больше одного"
  end

  private

  def document_pages(length)
    pages = length / APPROXIMATE_PAGE_LENGTH.to_f
    dec = pages - pages.to_i
    dec < 0.6 ? "#{pages.floor} с небольшим" : pages.floor
  end

  def document_length
    length = document_object.body.content.last.end_index
    length = MIN_CHUNK_LENGTH if length < MIN_CHUNK_LENGTH
    length
  end

  def document_object
    @document_object ||= get_document_object(document_id)
  end

  def chat
    @chat ||= Chat.find_or_create_by id: chat_id
  end

  def document
    @document ||= Document.find_or_initialize_by chat_id: chat.id, document_id: document_id
  end

  def chat_id
    params[:chat_id]
  end

  def document_id
    params[:document_id]
  end
end
