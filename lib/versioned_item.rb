require "versioned_item/version"
require 'versioned_item/item'

module VersionedItem
  class VersionsNotConfigured < StandardError; end
  class VersionNotFound < StandardError; end
  class ItemNotFound < StandardError; end

  @class_map = {}
  @available_versions = []

  class << self
    def available_versions=(versions)
      @available_versions = versions.map(&:to_s)
    end
    attr_reader :available_versions

    attr_accessor :class_map
  end
end
