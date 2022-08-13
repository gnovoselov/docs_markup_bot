# frozen_string_literal: true

require 'telegram/bot'

class DividerService < ApplicationService

  def call
    Document.pending.where('created_at < ?', 15.minutes.ago).each do |document|
      next if document.participants.count < 1

      document.active!
      divide_document(document)
    end
  end

  def divide_document(document)
    FormatService.perform(
      document_id: document.document_id,
      parts: document.participants.count,
      participants: document.participants
    )

    references = []
    document.participants.each_with_index do |participant, i|
      references << "@#{participant.username}" if participant.username.present?
      WipService.perform(
        document_id: document.document_id,
        part: i + 1,
        wip: true,
        username: participant.full_name
      )
    end

    Telegram::Bot::Client.run(TELEBOT_CONFIG['token']) do |bot|
      bot.api.send_message(
        chat_id: document.chat_id,
        text: "#{references.join(' ')} \nOK. Документ разделен на части! Можно приступать к переводу. По окончании нажмите, пожалуйста, /finish"
      )
    end
  end
end
