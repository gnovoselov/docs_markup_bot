# frozen_string_literal: true

class StartMessageService < ApplicationService
  # @attr_reader params [Hash]
  # - chat_id: [Integer] Telegram chat ID
  # - document_id: [String] Google Docs ID

  include DocumentsApiConcern
  include SemanticsConcern

  OPTIMAL_CHUNK_LENGTH = 1350

  def call
    return unless chat_id && document_id

    if document.persisted?
      return "Работа над документом завершена" if document.done?
      return "Документ уже в работе"
    end

    length = document_length(document_object)

    return "Этот документ пуст или недоступен!" if length == 0

    result = []
    chat.inactivate_all!
    document.max_participants = length / min_chunk_length
    document.optimal_participants = length / OPTIMAL_CHUNK_LENGTH
    document.pending!

    notifications = []
    chat.participants.find_each do |participant|
      participant.subscriptions.each do |subscription|
        notifications << {
          text: "Привет! У нас есть новый документ для перевода: #{TELEGRAM_CHAT_URL}",
          chat_id: subscription.chat_id
        }
      end
    end

    NotificationsService.perform(notifications: notifications)

    result << "Друзья, у нас есть новый документ для перевода!\nСтраниц в нем примерно #{document_pages(length)}.\n\nКто участвует, нажмите, пожалуйста, /in\nПосле команды можно добавить количество кусочков, которые вы сегодня готовы перевести, если их больше одного"

    chat.waiters.find_each do |waiter|
      doc_participant = DocumentParticipant.create(
        document_id: document.id,
        participant_id: waiter.participant_id,
        parts: waiter.parts
      )
      reference = ''
      reference = "@#{waiter.participant.username} " if waiter.participant.username
      result << "#{reference}#{waiter.participant.full_name}, вам назначено #{waiter.parts} #{parts_caption(waiter.parts)}"
      waiter.destroy
    end

    result
  end

  private

  def chat
    @chat ||= Chat.find_or_create_by id: chat_id
  end

  def document
    @document ||= Document.find_or_initialize_by chat_id: chat.id, document_id: document_id
  end

  def document_object
    @document_object ||= get_document_object(document_id)
  end

  def chat_id
    params[:chat_id]
  end

  def document_id
    params[:document_id]
  end

  def add_participant_service
    AddParticipantService
  end
end
