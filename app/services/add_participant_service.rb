# frozen_string_literal: true

class AddParticipantService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return if !message || !chat || !document || document.active?

    result = []
    if doc_participant.persisted?
      "Вы уже участвуете в переводе этого документа. Нас #{load_participants_count}"
    else
      doc_participant.save
      count = load_participants_count
      result << "#{express_joy}! Теперь нас #{count}"
      if count >= document.max_participants
        result << "Всем спасибо! Для перевода этого документа уже достаточно добровольцев!"
        Thread.new { divider_service.divide_document(document) }
      end
    end

    result
  end

  private

  def message
    params[:message]
  end

  def divider_service
    @divider_service ||= DividerService.new
  end

  def chat
    @chat ||= Chat.find_by id: message.chat.id
  end

  def document
    @document ||= chat&.documents.pending.last
  end

  def participant
    @participant ||= Participant.find_or_create_by(
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username
    )
  end

  def doc_participant
    @doc_participant ||= DocumentParticipant.find_or_initialize_by(
      document_id: document.id,
      participant_id: participant.id
    )
  end

  def load_participants_count
    document.reload.participants.count
  end
end
