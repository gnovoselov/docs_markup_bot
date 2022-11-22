# frozen_string_literal: true

class StatusService < ApplicationService
  # @attr_reader params [Hash]
  # - message: [Telegram::Bot::Types::Message] Incoming message

  include DocumentsApiConcern
  include SemanticsConcern

  def call
    case document&.status
    when 'pending'
      "Набираем волонтеров для перевода текущего документа.\nСтраниц в нем примерно #{pages}.\nПока делим на #{total_parts} #{parts_caption(total_parts)}.\n\n#{pending_participant_status}"
    when 'active'
      "Перевод документа в процессе.\nОн разделен на #{total_parts} #{parts_caption(total_parts)}.\nВ работе еще #{in_progress_parts}.\n\n#{participant_status}"
    else
      "Сейчас никаких переводов не ведется.\n#{waiter_status}#{other_waiters_status}"
    end
  end

  private

  def pending_participant_status
    return "Вы не участвуете в переводе этого документа.\nДля участия нажмите /in" unless doc_participant

    "Вы участвуете в переводе этого документа.\nУ вас #{doc_participant.parts} #{parts_caption(doc_participant.parts)}"
  end

  def participant_status
    return "Вы не участвуете в переводе этого документа.\nДля участия в переводе следующего нажмите /wait" unless doc_participant

    case doc_participant.status
    when 'inactive'
      "Вы уже завершили перевод своих частей текста.\nИх было у вас в работе #{doc_participant.parts}"
    else
      "Вы участвуете в переводе.\nУ вас в работе #{doc_participant.parts} #{parts_caption(doc_participant.parts)}"
    end
  end

  def other_waiters_status
    return unless waiter_parts_count > 0

    "\n\nВсего есть заявок на #{waiter_parts_count} #{parts_caption(waiter_parts_count)}."
  end

  def waiter_status
    waiter ?
      "От вас есть заявка на #{waiter.parts} #{parts_caption(waiter.parts)} в следующем документе." :
      "Вы можете записаться на перевод следующего документа командой /wait"
  end

  def waiter_parts_count
    @waiter_parts_count ||= chat.waiters&.sum(&:parts)
  end

  def pages
    @pages ||= document_pages(
      document_length(document_object)
    )
  end

  def total_parts
    @total_parts ||= load_parts_count(document)
  end

  def in_progress_parts
    @in_progress_parts ||= load_participants_count(document)
  end

  def message
    params[:message]
  end

  def chat
    @chat ||= Chat.find_by id: message.chat.id
  end

  def document
    @document ||= chat&.documents&.last
  end

  def document_object
    @document_object ||= get_document_object(document.document_id)
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
      participant_id: participant.id
    )
  end

  def waiter
    @waiter = chat.waiters.find_by(participant_id: participant.id)
  end
end
