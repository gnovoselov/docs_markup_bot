# frozen_string_literal: true

class ShareService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - part: [Integer] Which part to share (default 1)

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return unless message && chat && document

    return "Перевод документа еще не стартовал. Если вы передумали, нажмите /out" if document.pending?

    return "Перевод документа уже завершен" unless document.active?

    return "Вы не участвуете в переводе этого документа" unless doc_participant

    return "У вас в работе всего #{doc_participant.parts} #{parts_caption(doc_participant.parts)}" if doc_participant.parts < part

    Share.create(
      participant_id: participant.id,
      document_id: document.id,
      part: part
    )
    left_parts = part == 0 ? 0 : doc_participant.parts - 1

    if left_parts == 0
      doc_participant.parts = left_parts
      doc_participant.inactive!
    else
      doc_participant.update(parts: left_parts)
    end

    notifications = []
    chat.participants.find_each do |participant|
      participant.subscriptions.each do |subscription|
        notifications << {
          text: "Кому-то нужна ваша помощь в переводе. Загляните, пожалуйста, в чат, если можете взять дополнительную работу: #{TELEGRAM_CHAT_URL}",
          chat_id: subscription.chat_id
        }
      end
    end
    NotificationsService.perform(notifications: notifications)

    "Друзья, нужна помощь! Кто может взять в работу дополнительный кусок, нажмите, пожалуйста, /take"
  end

  private

  def message
    params[:message]
  end

  def part
    params[:part] || 0
  end

  def chat
    @chat ||= Chat.find_by id: message.chat.id
  end

  def document
    @document ||= chat&.documents&.last
  end

  def participant
    @participant ||= Participant.find_or_create_by(
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username
    )
  end

  def doc_participant
    @doc_participant ||= DocumentParticipant.find_by(
      document_id: document.id,
      participant_id: participant.id
    )
  end
end
