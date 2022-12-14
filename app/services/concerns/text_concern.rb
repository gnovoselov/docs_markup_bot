# frozen_string_literal: true

require "google/apis/docs_v1"

module TextConcern
  extend ActiveSupport::Concern

  private

  def set_text(element, text)
    Google::Apis::DocsV1::Request.new(
      replace_all_text: Google::Apis::DocsV1::ReplaceAllTextRequest.new(
        contains_text: Google::Apis::DocsV1::SubstringMatchCriteria.new(
          text: element.content
        ),
        replace_text: text
      )
    )
  end

  def insert_text_before(start_index, content)
    Google::Apis::DocsV1::Request.new(
      insert_text: Google::Apis::DocsV1::InsertTextRequest.new(
        location: Google::Apis::DocsV1::Location.new(
          index: start_index
        ),
        text: content
      )
    )
  end

  def remove_text(text)
    Google::Apis::DocsV1::Request.new(
      replace_all_text: Google::Apis::DocsV1::ReplaceAllTextRequest.new(
        replace_text: '',
        contains_text: Google::Apis::DocsV1::SubstringMatchCriteria.new(
          text: text
        )
      )
    )
  end

  def update_text_background(start_index, end_index, text_style)
    Google::Apis::DocsV1::Request.new(
      update_text_style: Google::Apis::DocsV1::UpdateTextStyleRequest.new(
        fields: 'background_color',
        range: Google::Apis::DocsV1::Range.new(
          start_index: start_index,
          end_index: end_index
        ),
        text_style: text_style
      )
    )
  end

  def update_text_style(start_index, end_index, text_style)
    Google::Apis::DocsV1::Request.new(
      update_text_style: Google::Apis::DocsV1::UpdateTextStyleRequest.new(
        fields: text_style.keys.join(','),
        range: Google::Apis::DocsV1::Range.new(
          start_index: start_index,
          end_index: end_index
        ),
        text_style: Google::Apis::DocsV1::TextStyle.new(**text_style)
      )
    )
  end

  def remove_element(element)
    remove_range(element.start_index, element.end_index)
  end

  def remove_range(start_index, end_index)
    Google::Apis::DocsV1::Request.new(
      delete_content_range: Google::Apis::DocsV1::DeleteContentRangeRequest.new(
        range: Google::Apis::DocsV1::Range.new(
          start_index: start_index,
          end_index: end_index
        )
      )
    )
  end

  def create_color(red, green, blue)
    Google::Apis::DocsV1::OptionalColor.new(
      color: Google::Apis::DocsV1::Color.new(
        rgb_color: Google::Apis::DocsV1::RgbColor.new(
          red: red,
          green: green,
          blue: blue
        )
      )
    )
  end
end
