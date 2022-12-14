# frozen_string_literal: true

require "google/apis/docs_v1"

module WipConcern
  extend ActiveSupport::Concern

  WIP = "WIP".freeze
  WIP_OTHERS = /^[\s\t]*\[#{WIP} ([^\]]+)\][\s\t]*/
  DUPLICATED_LINK_CAPTION = ' [DUPLICATED LINK] '
  LINK_DUPLICATE_CAPTION = ' [LINK DUPLICATE] '

  private

  def get_wip_text(username)
    " [#{WIP} #{username}] "
  end

  def remove_non_ascii(text)
    return '' unless text

    text.encode(Encoding.find('ASCII'), :invalid => :replace, :undef => :replace, :replace => '')
  end

  def duplicated_link_caption?(element)
    element.text_run&.content == DUPLICATED_LINK_CAPTION ||
      element.text_run&.content == LINK_DUPLICATE_CAPTION
  end
end
