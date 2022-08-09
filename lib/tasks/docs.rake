# frozen_string_literal: true

namespace :docs do
  task divide: [ :environment ] do
    FormatService.perform(document_id: ARGV.first, parts: ARGV.second || nil)
  end
end
