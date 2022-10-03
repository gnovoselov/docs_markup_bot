# frozen_string_literal: true

class RemoveParticipantService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return if !message || !chat || !document || !document.pending?

    result = []
    if doc_participant.persisted?
      doc_participant.destroy
      "Вы больше не участвуете в переводе этого документа. Сейчас добровольцев: #{load_participants_count}"
    else
      "Вы не участвуете в переводе этого документа. Сейчас добровольцев: #{load_participants_count}"
    end
  end

  private

  def message
    params[:message]
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
