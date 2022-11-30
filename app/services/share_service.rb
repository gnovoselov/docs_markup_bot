# frozen_string_literal: true

class ShareService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - part: [Integer] Which part to share (default 1)
  # - force: [Boolean] If we're forcing a participant to share his parts
  # - participant: [String] Participant Full name or login to share parts from

  include DocumentsApiConcern
  include SemanticsConcern
  include AdminConcern

  def call
    return unless message && chat && document

    return "Перевод документа еще не стартовал. Если вы передумали, нажмите /out" if document.pending?

    return "Перевод документа уже завершен" unless document.active?

    if param_force
      return "У вас недостаточно прав, чтобы отдать чужой кусок в работу кому-то другому" unless is_admin?(participant)

      return "Указанный вами человек не найден или не участвует в переводе текущего документа" unless sharing_participant && doc_participant
    else
      return "Вы не участвуете в переводе этого документа" unless doc_participant

      return "У вас в работе всего #{doc_participant.parts} #{parts_caption(doc_participant.parts)}" if doc_participant.parts < part
    end

    Share.create(
      participant_id: sharing_participant.id,
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
    chat.participants.find_each do |chat_participant|
      chat_participant.subscriptions.each do |subscription|
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

  def param_force
    params[:force]
  end

  def param_participant
    params[:participant]
  end

  def participant_props
    /^@/.match?(param_participant) ?
      [{ username: param_participant[1..-1] }] :
      ["first_name || ' ' || last_name = ? OR first_name = ?", param_participant, param_participant]
  end

  def load_participant
    chat.participants.find_by(*participant_props)
  end

  def sharing_participant
    @sharing_participant ||= param_force ? load_participant : participant
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
      participant_id: sharing_participant.id
    )
  end
end
