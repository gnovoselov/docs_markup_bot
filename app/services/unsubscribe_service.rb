# frozen_string_literal: true

class UnsubscribeService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  def call
    return "Вы не подписаны на оповещения" unless subscription

    subscription.destroy

    "Вам больше не будут приходить личные сообщения о документах в других чатах."
  end

  private

  def message
    params[:message]
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

  def subscription
    @subscription ||= Subscription.find_by(
      participant_id: participant.id,
      chat_id: chat.id
    )
  end
end
