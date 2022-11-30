# frozen_string_literal: true

module BackgroundsConcern
  extend ActiveSupport::Concern

  include TextConcern

  ALLOWED_COLORS = [
    [1, 1, 1],
    [0.90, 0.82, 0.99],
    [0.98, 0.76, 0.68],
    [0.79, 0.92, 0.82],
    [1, 0.96, 0.57],
    [0.9, 0.93, 0.93],
    [0.96, 0.84, 0.93],
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
  def update_background(element, obj, color_index = 0, dept = 0)
    text_style = element.public_send(obj).text_style
    text_style&.update!(
      background_color: create_color(*ALLOWED_COLORS[color_index])
    )

    update_text_background(element.start_index + dept, element.end_index + dept, text_style)
  end
end
