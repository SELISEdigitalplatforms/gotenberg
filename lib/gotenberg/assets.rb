# frozen_string_literal: true

module Gotenberg
  module Assets
    ASSET_TYPES = {
      "js" => "javascripts",
      "css" => "stylesheets",

      # Fonts
      "otf" => "fonts",
      "ttf" => "fonts",
      "woff" => "fonts",
      "woff2" => "fonts",
      "eot" => "fonts",
      "sfnt" => "fonts",
      "fnt" => "fonts",
      "pfa" => "fonts",
      "pfb" => "fonts",
      "afm" => "fonts",
      "pcf" => "fonts",
      "snf" => "fonts",
      "bdf" => "fonts",

      # Images
      "bmp" => "images",
      "gif" => "images",
      "jpg" => "images",
      "jpeg" => "images",
      "png" => "images",
      "svg" => "images",
      "tiff" => "images",
      "tif" => "images",
      "webp" => "images",
      "ico" => "images",
      "psd" => "images",
      "heic" => "images"
    }.freeze
  end
end
