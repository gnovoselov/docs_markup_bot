# frozen_string_literal: true

class WaitService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message
  # - parts: [Integer] How many parts to allocate to the participant
  # - cancel: [Boolean] Cancel waiting. Default: false
  # - participant: [Participant] Participant to cancel waiting

  include DocumentsApiConcern
  include SemanticsConcern
  include AdminConcern
  include ParticipantConcern

  def call
    return unless message && chat

    param_cancel ? stop_waiting : wait
  end

  private

  def wait
    result = if waiter.persisted?
                "Вы уже ждете следующий документ. У вас будет #{parts} #{parts_caption(parts)}"
              else
                "Спасибо за вашу заявку! Как только появится новый документ, у вас будет #{parts} #{parts_caption(parts)}. Вы можете отписаться командой /unwait"
              end

    waiter.update(parts: parts)

    result
  end

  def stop_waiting
    return cancel_somebody_waiting if param_participant

    return "От вас не было заявки на перевод следующего документа" unless waiter.persisted?

    destroy_waiter

    "Ничего! Все планы меняются. Не расстраивайтесь: вы сможете помочь с переводом в следующий раз!"
  end

  def cancel_somebody_waiting
    return "У вас недостаточно полномочий, чтобы решать, кто не будет переводить следующий документ" unless is_admin?(participant)

    return "Указанный вами человек не найден или не ждет перевода следующего документа" unless waiting_participant && waiter.persisted?

    comment = waiter.persisted? ? "не будет участвовать в переводе" : "не ожидает перевода"
    destroy_waiter

    "Пользователь #{waiting_participant.full_name} #{comment} следующего документа"
  end

  def destroy_waiter
    waiter.destroy
  end

  def message
    params[:message]
  end

  def parts
    params[:parts] || 1
  end

  def param_cancel
    params[:cancel] || false
  end

  def param_participant
    params[:participant]
  end

  def waiting_participant
    @waiting_participant ||= param_participant ? load_participant : participant
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
      participant_id: waiting_participant.id,
      chat_id: chat.id
    )
  end
end
