# frozen_string_literal: true

class FinishService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - force: [Boolean] If we have to force finishing document

  include DocumentsApiConcern
  include SemanticsConcern
  include AdminConcern

  def call
    return unless document

    if param_force
      return "У вас нет прав на принудительное завершение работы над документом" unless is_admin?(participant)
    else
      return "Вы не участвуете в переводе текущего документа или перевод уже завершен" unless doc_participant

      WipRemoveService.perform(
        document_id: document&.document_id,
        username: participant.full_name
      )

      participant.shares.where(document_id: document.id).delete_all
      doc_participant.inactive!
      count = load_participants_count(document)
    end

    if param_force || count < 1
      ClearService.perform(document_id: document&.document_id)
      document.done!

      references = document.participants
                            .map { |p| "@#{p.username}" if p.username }
                            .compact
                            .join(' ')
      TELEGRAM_ADMIN_CHATS.each do |chat|
        NotificationsService.perform(notifications: [{
          chat_id: chat,
          text: "Перевод готов: #{document.url}"
        }])
      end

      [
        "#{references} \nСпасибо всем за работу!",
        "#{TELEGRAM_ADMINS.map { |a| "@#{a}" }.join(' ')} Перевод готов #{document.url}"
      ]
    else
      "#{express_joy}! В работе еще #{count} #{parts_caption(count)}"
    end
  end

  private

  def message
    params[:message]
  end

  def param_force
    params[:force]
  end

  def chat
    @chat ||= Chat.find_by id: message.chat.id
  end

  def document
    @document ||= chat&.documents&.active&.last
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
      document_id: document&.id,
      participant_id: participant&.id
    )
  end
end
