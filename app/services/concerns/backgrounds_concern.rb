# frozen_string_literal: true

require "google/apis/docs_v1"

module BackgroundsConcern
  extend ActiveSupport::Concern

  ALLOWED_COLORS = [
    [1, 1, 1],          # white
    [1, 0.01, 1],       # fuchsia
    [0.29, 0.53, 0.9],  # light blue
    [0, 1, 0],          # green
    [0.04, 1, 1],       # turquoise
    [1, 1, 0],          # yellow
    [0.6, 0, 1],        # purple
    [1, 0.6, 0],        # orange
    [1, 0, 0],          # red
    [0.85, 0.85, 0.85], # grey
    [0.84, 0.65, 0.74], # pink
    [0.75, 0.56, 0.01], # beige
    [0.6, 0, 0],        # brown
    [0.2, 0.11, 0.07],  # eggplant
    [0.15, 0.3, 0.08],  # dark green
    [0.85, 0.82, 0.91], # lavander
    [0.71, 0.84, 0.66], # spring
    [0.07, 0, 1],       # blue
    [0.05, 0.2, 0.24],  # teal
    [0.45, 0.11, 0.28], # plum
    [0.04, 0.22, 0.39], # navy blue
  ]

  private

  # Sets white background by default
  def update_background(element, obj, color_index = 0)
    text_style = element.public_send(obj).text_style
    text_style&.update!(
      background_color: create_color(*ALLOWED_COLORS[color_index])
    )

    Google::Apis::DocsV1::Request.new(
      update_text_style: Google::Apis::DocsV1::UpdateTextStyleRequest.new(
        fields: 'background_color',
        range: Google::Apis::DocsV1::Range.new(
          start_index: element.start_index,
          end_index: element.end_index
        ),
        text_style: text_style
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
