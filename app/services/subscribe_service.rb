# frozen_string_literal: true

class SubscribeService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  def call
    return "Вы уже подписаны на оповещения" if subscription.persisted?

    return "Это сообщение должно быть отправлено боту В ЛИЧКУ" if chat.participants.uniq.count > 1

    subscription.save

    "Теперь вам будут приходить личные сообщения при появлении документов для перевода в других чатах. Также сообщения будут приходить, когда документ размечен, и перевод можно начинать."
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
    @subscription ||= Subscription.find_or_initialize_by(
      participant_id: participant.id,
      chat_id: chat.id
    )
  end
end
