# frozen_string_literal: true

require "google/apis/docs_v1"

module BackgroundsConcern
  extend ActiveSupport::Concern

  ALLOWED_COLORS = [
    [1, 1, 1],
    [0.66, 0.51, 0.82],
    [0.98, 0.76, 0.68],
    [0.79, 0.92, 0.82],
    [1, 0.96, 0.57],
    [0.9, 0.93, 0.93],
    [0.84, 0.33, 0.71],
    [0.92, 0.71, 0.77],
    [0.74, 0.82, 0.47],
    [0.97, 0.72, 0.45],
    [0.6, 0.79, 0.81],
    [0.72, 0.75, 0.96],
    [0.86, 0.85, 0.56],
    [1, 0.01, 1],       # fuchsia
    [0.29, 0.53, 0.9],  # blue
    [0, 1, 0],          # green
    [0.04, 1, 1],       # turquoise
    [1, 1, 0],          # yellow
    [1, 0.6, 0],        # orange
    [1, 0, 0],          # red
    [0.6, 0, 1],        # purple
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
