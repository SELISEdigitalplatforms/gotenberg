# frozen_string_literal: true

require "rails"
require "gotenberg/helper"

module Gotenberg
  class Railtie < Rails::Railtie # rubocop:disable Style/Documentation
    initializer "gotenberg.register" do
      ActiveSupport.on_load :action_view do
        include Gotenberg::Helper
      end
    end
  end
end
