# frozen_string_literal: true

namespace :divider do
  task perform: [ :environment ] do
    DividerService.perform
  end
end
