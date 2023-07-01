# frozen_string_literal: true

class AddParticipantService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - parts: [Integer] How many parts to allocate to the participant

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return unless message && chat && document && document.pending?

    result = []
    persisted = doc_participant.persisted?
    parts = params[:parts] || 1
    if parts.to_i > 1
      result << "По новым правилам мы больше не можем брать в работу несколько частей. Вам будет назначена одна часть."
      parts = 1
    end
    doc_participant.update(parts: parts)
    count = load_parts_count(document)
    caption = persisted ? "Вы уже участвуете в переводе этого документа. Всего у вас #{parts} #{parts_caption(parts)}." : "#{express_joy}!"
    result << "#{caption} Делим на #{count}"

    if count >= document.max_participants
      result << "Всем спасибо! Для перевода этого документа уже достаточно добровольцев!"
      Thread.new { divider_service.divide_document(document) }
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
end
