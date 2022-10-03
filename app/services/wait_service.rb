# frozen_string_literal: true

class WaitService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - parts: [Integer] How many parts to allocate to the participant

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    return unless message && chat

    message = if waiter.persisted?
                "Вы уже ждете следующий документ. Вам будет назначено частей: #{parts}"
              else
                "Спасибо за вашу заявку! Как только появится новый документ, вам будет назначено частей: #{parts}"
              end

    waiter.update(parts: parts)

    message
  end

  private

  def message
    params[:message]
  end

  def parts
    params[:parts] || 1
  end

  def chat
    @chat ||= Chat.find_or_create_by id: message.chat.id
  end

  def participant
    @participant ||= Participant.find_or_create_by(
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username
    )
  end

  def waiter
    @waiter ||= Waiter.find_or_initialize_by(
      participant_id: participant.id,
      chat_id: chat.id
    )
  end
end
