# frozen_string_literal: true

require_relative "gotenberg/version"
require_relative "gotenberg/client"
require_relative "gotenberg/railtie" if defined?(Rails::Railtie)
require_relative "gotenberg/helper"

module Gotenberg
  class GotenbergDownError < StandardError; end
end
