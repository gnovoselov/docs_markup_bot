# frozen_string_literal: true

class RemoveParticipantService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - participant: [Participant] Participant to cancel translation

  include DocumentsApiConcern
  include SemanticsConcern
  include ParticipantConcern
  include AdminConcern

  def call
    return if !message || !chat || !document || !document.pending?

    if doc_participant.persisted?
      caption = 'Вы больше не участвуете'
      if param_participant
        return "У вас нет прав на принудительное исключение переводчиков" unless is_admin?(participant)

        caption = "#{doc_participant.participant.full_name} больше не участвует"
        notifications = []
        doc_participant.participant.subscriptions.each do |subscription|
          notifications << {
            text: "Вас исключили из числа переводчиков документа #{document.url}",
            chat_id: subscription.chat_id
          }
          NotificationsService.perform(notifications: notifications)
        end
      end
      doc_participant.destroy
      "#{caption} в переводе этого документа. Сейчас добровольцев: #{load_participants_count}"
    else
      "#{param_participant ? "#{param_participant} не участвует" : 'Вы не участвуете'} в переводе этого документа. Сейчас добровольцев: #{load_participants_count}"
    end
  end

  private

  def message
    params[:message]
  end

  def param_participant
    params[:participant]
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

  def waiting_participant
    @waiting_participant ||= param_participant ? load_participant : participant
  end

  def doc_participant
    @doc_participant ||= DocumentParticipant.find_or_initialize_by(
      document_id: document.id,
      participant_id: waiting_participant&.id
    )
  end

  def load_participants_count
    document.reload.participants.count
  end
end
