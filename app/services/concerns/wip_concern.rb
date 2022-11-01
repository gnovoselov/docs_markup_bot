# frozen_string_literal: true

require "google/apis/docs_v1"

module WipConcern
  extend ActiveSupport::Concern

  WIP = "WIP".freeze
  WIP_OTHERS = /^\s?\[#{WIP} ([^\]]+)\]/

  private

  def get_wip_text(username)
    " [#{WIP} #{username}] "
  end

  def remove_non_ascii(text)
    return '' unless text

    text.encode(Encoding.find('ASCII'), :invalid => :replace, :undef => :replace, :replace => '')
  end
end
