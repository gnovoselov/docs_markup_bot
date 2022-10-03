# frozen_string_literal: true

class WipReplaceService < ApplicationService
  # @attr_reader params [Hash]
  # - document_id: [String] Google document ID
  # - from: [String] From user name
  # - to: [String] To user name
  # - part: [Integer] Number of mark to be replaced. 0 means all of them (default 0)

  include DocumentsApiConcern
  include TextConcern
  include WipConcern

  def call
    old_wip_text = get_wip_text(params[:from])
    new_wip_text = get_wip_text(params[:to])
    dept = 0
    count = 0
    changed = 0
    change_document(params[:document_id]) do |document, structural_element, requests|
      if structural_element.paragraph
        structural_element.paragraph.elements.each do |element|
          next if element&.text_run&.content&.blank?

          if /[\s\t]*#{Regexp.escape(remove_non_ascii(old_wip_text).strip)}[\s\t]*/.match?(remove_non_ascii(element.text_run.content))
            count += 1
            if part == 0 || part == count
              changed += 1
              requests << insert_text_before(element.start_index + dept, new_wip_text)
              dept += new_wip_text.length
              requests << remove_range(element.start_index + dept, element.end_index + dept)
              dept -= element.end_index - element.start_index
            end
          end
        end
      end
    end
    changed
  end

  private

  def part
    params[:part] || 0
  end
end
