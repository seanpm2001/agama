# frozen_string_literal: true

# Copyright (c) [2022-2023] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "yaml"
require "yast2/arch_filter"
require "agama/config_reader"

module Agama
  # Class responsible for getting current configuration.
  # It is smarter then just plain yaml reader as it also evaluates
  # conditions in it, so it is result of all conditions in file.
  # This also means that config needs to be re-evaluated if conditions
  # data change, like if user pick different distro to install.
  class Config
    # @return [Hash] configuration data
    attr_accessor :pure_data

    class << self
      attr_accessor :current, :base

      # Loads base and current config reading configuration from the system
      def load(logger = Logger.new($stdout))
        @base = ConfigReader.new(logger: logger).config
        @current = @base&.copy
      end

      # It resets the configuration internal state
      def reset
        @base = nil
        @current = nil
      end

      # Load the configuration from a given file
      #
      # @param path [String|Pathname] File path
      def from_file(path)
        new(YAML.safe_load(File.read(path.to_s)))
      end
    end

    # Constructor
    #
    # @param config_data [Hash] configuration data
    def initialize(config_data = nil)
      @pure_data = config_data
    end

    # parse loaded yaml file, so it properly applies conditions
    # with default options it load file without conditions
    def parse_file(_arch = nil, _distro = nil)
      # TODO: move to internal only. public one should be something
      # like evaluate or just setter for distro and arch
      # logger.info "parse file with #{arch} and #{distro}"
      # TODO: do real evaluation of conditions
      data
    end

    def data
      return @data if @data

      @data = @pure_data.dup || {}
      pick_product(products.keys.first) unless products.empty?
      @data
    end

    def pick_product(product)
      data.merge!(data[product])
    end

    # list of available base products for current architecture
    def products
      return @products if @products
      return [] unless @pure_data && @pure_data["products"]

      # cannot use `data` here to avoid endless loop as in data we use
      # pick_product that select product from products
      @products = @pure_data["products"].select { |_k, v| arch_match?(v["archs"]) }
    end

    # Whether there are more than one product
    #
    # @return [Boolean] false if there is only one product; true otherwise
    def multi_product?
      products.size > 1
    end

    # Returns a copy of this Object
    #
    # @return [Config]
    def copy
      Marshal.load(Marshal.dump(self))
    end

    # Returns a new {Config} with the merge of the given ones
    #
    # @param config [Config, Hash]
    # @return [Config] new Configuration with the merge of the given ones
    def merge(config)
      Config.new(simple_merge(data, config.data))
    end

    # Elements that match the current arch.
    #
    # @example
    #   config.pure_data = {
    #     "ALP-Dolomite" => {
    #       "software" => {
    #         "installation_repositories" => [
    #           {
    #             "url" => "https://updates.suse.com/SUSE/Products/ALP-Dolomite/1.0/x86_64/product/",
    #             "archs" => "x86_64"
    #           },
    #           {
    #             "url" => https://updates.suse.com/SUSE/Products/ALP-Dolomite/1.0/aarch64/product/",
    #             "archs" => "aarch64"
    #           },
    #           "https://updates.suse.com/SUSE/Products/ALP-Dolomite/1.0/noarch/"
    #         ]
    #       }
    #     }
    #   }
    #
    #   Yast::Arch.rpm_arch #=> "x86_64"
    #   config.arch_elements_from("ALP-Dolomite", "software", "installation_repositories",
    #     property: :url) #=> ["https://.../SUSE/Products/ALP-Dolomite/1.0/x86_64/product/",
    #                     #=>  "https://updates.suse.com/SUSE/Products/ALP-Dolomite/1.0/noarch/"]
    #
    # @param keys [Array<Symbol|String>] Config data keys of the collection.
    # @param property [Symbol|String|nil] Property to retrieve of the elements.
    #
    # @return [Array]
    def arch_elements_from(*keys, property: nil)
      keys.map!(&:to_s)
      elements = pure_data.dig(*keys)
      return [] unless elements.is_a?(Array)

      elements.map do |element|
        if !element.is_a?(Hash)
          element
        elsif arch_match?(element["archs"])
          property ? element[property.to_s] : element
        end
      end.compact
    end

  private

    # Simple deep merge
    #
    # @param a_hash       [Hash] Default values
    # @param another_hash [Hash] Pillar data
    # @return [Hash]
    def simple_merge(a_hash, another_hash)
      a_hash.reduce({}) do |all, (k, v)|
        next all.merge(k => v) if another_hash[k].nil?

        if v.is_a?(Hash)
          all.merge(k => simple_merge(a_hash[k], another_hash[k]))
        else
          all.merge(k => another_hash[k])
        end
      end
    end

    # Whether the current arch matches any of the given archs.
    #
    # @param archs [String] E.g., "x86_64,aarch64"
    # @return [Boolean]
    def arch_match?(archs)
      return true if archs.nil?

      Yast2::ArchFilter.from_string(archs).match?
    end
  end
end
