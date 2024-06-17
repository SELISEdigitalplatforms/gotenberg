# frozen_string_literal: true

module Gotenberg
  module Helper # rubocop:disable Style/Documentation
    class ExtensionMissing < StandardError; end

    class PropshaftAsset # rubocop:disable Style/Documentation
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

    def goten_asset_base64(asset_name)
      asset = find_asset(goten_static_asset_path(asset_name))
      raise MissingAsset.new(asset_name, "Could not find asset '#{asset_name}'") if asset.nil?

      base64 = Base64.encode64(asset.to_s).delete("\n")
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
    end

    def goten_static_asset_path(asset_name)
      ext = File.extname(asset_name).delete(".")

      raise ExtensionMissing if ext.empty?

      asset_type =
        case ext
        when "js" then "javascripts"
        when "css" then "stylesheets"
        else "images"
        end

      determine_static_path(asset_type, asset_name)
    end

    def goten_compiled_asset_path(asset_name)
      Rails.public_path.to_s +
        ActionController::Base.helpers.asset_path(asset_name)
    end

    private

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

    # Thanks WickedPDF 🙏
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
