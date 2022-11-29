# frozen_string_literal: true

class TakeService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return unless message && chat && document

    return "Перевод документа еще не стартовал. Если вы хотите взять дополнительный кусок. воспользуйтесь командой /in с указанием количества" if document.pending?

    return "Перевод документа уже завершен" unless document.active?

    return "Эта команда используется для того, чтобы взять в работу чужой кусок, если кто-то хочет им поделиться. Для вызова справки нажмите /start" unless share

    doc_participant.parts = 0 unless doc_participant.persisted?
    parts = WipReplaceService.perform(
      document_id: document&.document_id,
      from: share.participant.full_name,
      to: participant.full_name,
      part: share.part
    )
    doc_participant.parts += parts
    doc_participant.active!
    share.destroy

    "Спасибо за помощь! Вам назначена дополнительная работа. Теперь у вас #{doc_participant.parts} #{parts_caption(doc_participant.parts)}"
  end

  private

  def message
    params[:message]
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
    @doc_participant ||= DocumentParticipant.find_or_initialize_by(
      document_id: document.id,
      participant_id: participant.id
    )
  end

  def share
    @share ||= Share.find_by(document_id: document.id)
  end
end
