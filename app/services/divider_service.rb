# frozen_string_literal: true

require 'telegram/bot'

class DividerService < ApplicationService

  def call
    Document.pending.where('created_at < ?', 15.minutes.ago).each do |document|
      participants = document.participants.count
      next if participants < 1 ||
        (participants < document.optimal_participants && document.created_at > 35.minutes.ago)

      divide_document(document)
    end
  end

  def divide_document(document)
    document.active!
    FormatService.perform(
      document_id: document.document_id,
      parts: document.document_participants.sum(&:parts)
    )

    references = []
    part = 0
    document.document_participants.each do |doc_participant|
      participant = doc_participant.participant
      references << "@#{participant.username}" if participant.username.present?
      doc_participant.parts.times do |i|
        WipService.perform(
          document_id: document.document_id,
          part: part + i + 1,
          username: participant.full_name
        )
      end
      part += doc_participant.parts
    end

    duplicated_links_message = LinksService.perform(document_id: document.document_id)

    notifications = [{
      chat_id: document.chat_id,
      text: "#{references.join(' ')} \nOK. Документ разделен на части! Можно приступать к переводу.\n\n#{duplicated_links_message}\n\n#{document.url}\n\nПо окончании нажмите, пожалуйста, /finish"
    }]

    participant_ids = document.participants.map(&:id)

    document.chat.participants.find_each do |participant|
      next unless participant_ids.include?(participant.id)

      participant.subscriptions.each do |subscription|
        notifications << {
          text: "Документ разделен на части. Можно приступать: #{TELEGRAM_CHAT_URL}",
          chat_id: subscription.chat_id
        }
      end
    end
    NotificationsService.perform(notifications: notifications)
  end
end
