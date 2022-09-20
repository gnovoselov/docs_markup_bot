# frozen_string_literal: true

class RestartDocumentService < ApplicationService
  # @attr_reader params [Hash]
  # - chat_id: [Integer] Telegram chat ID
  # - document_id: [String] Google Docs ID

  def call
    return unless chat_id && document_id

    if document.active?
      document.participants.each do |participant|
        WipRemoveService.perform(
          document_id: document&.document_id,
          username: participant.full_name
        )
        ClearService.perform(document_id: document&.document_id)
      end
    end

    document.document_participants.destroy_all
    document.inactive!

    StartMessageService.perform(chat_id: chat.id, document_id: document_id)
  end

  private

  def chat
    @chat ||= Chat.find_or_create_by id: chat_id
  end

  def document
    @document ||= Document.find_or_initialize_by chat_id: chat.id, document_id: document_id
  end

  def chat_id
    params[:chat_id]
  end

  def document_id
    params[:document_id]
  end
end
