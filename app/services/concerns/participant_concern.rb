# frozen_string_literal: true

module ParticipantConcern
  extend ActiveSupport::Concern

  def participant_props
    /^@/.match?(param_participant) ?
      [{ username: param_participant[1..-1] }] :
      ["first_name || ' ' || last_name = ? OR first_name = ?", param_participant, param_participant]
  end

  def load_participant
    chat.participants.find_by(*participant_props)
  end
end
