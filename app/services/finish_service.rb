# frozen_string_literal: true

class FinishService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include SemanticsConcern

  def call
    if doc_participant
      WipRemoveService.perform(
        document_id: document&.document_id,
        username: participant.full_name
      )

      doc_participant.inactive!
      count = load_participants_count
      if count < 1
        ClearService.perform(document_id: document&.document_id)
        document.done!

        references = document.participants
                             .map { |p| "@#{p.username}" if p.username }
                             .compact
                             .join(' ')
        [
          "#{references} \nСпасибо всем за работу!",
          "@#{TELEGRAM_ADMIN} Перевод готов #{document.url}"
        ]
      else
        "#{express_joy}! В работе еще частей: #{count}"
      end
    else
      "Вы не участвуете в переводе текущего документа или перевод уже завершен"
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
    @document ||= chat&.documents.active.last
  end

  def participant
    @participant ||= document&.participants.find_by(
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username
    )
  end

  def doc_participant
    @doc_participant ||= DocumentParticipant.find_by(
      document_id: document&.id,
      participant_id: participant&.id
    )
  end

  def load_participants_count
    document.reload.document_participants.active.sum(&:parts)
  end
end
