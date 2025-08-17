# frozen_string_literal: true

require_relative "assets"

module Gotenberg
  module Helper # rubocop:disable Style/Documentation
    class ExtensionMissing < StandardError; end

    # Credits: https://github.com/mileszs/wicked_pdf/blob/master/lib/wicked_pdf/wicked_pdf_helper/assets.rb
    class PropshaftAsset
      attr_reader :asset

      def initialize(asset)
        @asset = asset
      end

      def content_type
        asset.content_type.to_s
      end

      def to_s
        asset.content
      end

      def filename
        asset.path.to_s
      end
    end

    class MissingAsset < StandardError # rubocop:disable Style/Documentation
      attr_reader :path

      def initialize(path, message)
        @path = path
        super(message)
      end
    end

    class LocalAsset # rubocop:disable Style/Documentation
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def content_type
        Mime::Type.lookup_by_extension(File.extname(path).delete("."))
      end

      def to_s
        File.read(path)
      end

      def filename
        path.to_s
      end
    end

    class SprocketsEnvironment # rubocop:disable Style/Documentation
      def self.instance
        @instance ||= Sprockets::Railtie.build_environment(Rails.application)
      end

      def self.find_asset(*args)
        instance.find_asset(*args)
      end
    end

    # Returns the base64 encoded content of an asset.
    #
    # @param asset_name [String] the name of the asset
    # @raise [MissingAsset] if the asset is not found
    # @return [String] the base64 encoded content of the asset
    def goten_asset_base64(asset_name)
      asset = find_asset(goten_static_asset_path(asset_name))
      raise MissingAsset.new(asset_name, "Could not find asset '#{asset_name}'") if asset.nil?

      base64 = Base64.encode64(asset.to_s).delete("\n")
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
    end

    # Returns the base64 encoded content of a static asset.
    #
    # @param asset_name [String] the name of the asset
    # @raise [MissingAsset] if the asset is not found
    # @return [String] the base64 encoded content of the asset
    def goten_static_asset_base64(asset_name)
      asset = LocalAsset.new(goten_static_asset_path(asset_name))
      raise MissingAsset.new(asset_name, "Could not find asset '#{asset_name}'") if asset.nil?

      base64 = Base64.encode64(asset.to_s).delete("\n")
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
    end
    
    # Returns the static path of an asset based on its extension.
    #
    # @param asset_name [String] the name of the asset
    # @raise [ExtensionMissing] if the asset extension is missing
    # @return [String] the static path of the asset
    def goten_static_asset_path(asset_name)
      ext = File.extname(asset_name).delete(".")

      raise ExtensionMissing if ext.empty?

      asset_type = Assets::ASSET_TYPES.fetch(ext)

      determine_static_path(asset_type, asset_name)
    end

    # Returns the compiled path of an asset.
    #
    # @param asset_name [String] the name of the asset
    # @return [String] the compiled path of the asset
    def goten_compiled_asset_path(asset_name)
      Rails.public_path.to_s +
        ActionController::Base.helpers.asset_path(asset_name)
    end

    # Returns the compiled name of an asset.
    #
    # @param asset_name [String] the name of the asset
    # @return [String] the compiled name of the asset
    def goten_compiled_asset_name(asset_name)
      path = goten_compiled_asset_path(asset_name)
      path.split("/").last
    end

    private

    # Determines and returns the static path of an asset.
    #
    # @param asset_type [String] the type of the asset (e.g., "javascripts", "stylesheets", "images")
    # @param asset_name [String] the name of the asset
    # @raise [MissingAsset] if the asset is not found
    # @return [String] the static path of the asset
    def determine_static_path(asset_type, asset_name)
      asset_root = Rails.root.join("app", "assets")
      path = asset_root.join(asset_type, asset_name)

      unless File.exist?(path)
        raise MissingAsset.new(
          asset_name,
          "Could not find static asset '#{asset_name}'"
        )
      end

      path.to_s
    end

    # Finds and returns the asset for the given path.
    #
    # @param path [String] the path of the asset
    # @return [PropshaftAsset, LocalAsset, Sprockets::Asset, nil] the found asset or nil if not found
    def find_asset(path)
      if Rails.application.assets.respond_to?(:find_asset)
        Rails.application.assets.find_asset(path, base_path: Rails.application.root.to_s)
      elsif defined?(Propshaft::Assembly) && Rails.application.assets.is_a?(Propshaft::Assembly)
        PropshaftAsset.new(Rails.application.assets.load_path.find(path))
      elsif Rails.application.respond_to?(:assets_manifest)
        asset_path = File.join(Rails.application.assets_manifest.dir, Rails.application.assets_manifest.assets[path])
        LocalAsset.new(asset_path) if File.file?(asset_path)
      else
        SprocketsEnvironment.find_asset(path, base_path: Rails.application.root.to_s)
      end
    end
  end
end
