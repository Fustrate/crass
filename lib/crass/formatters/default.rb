# encoding: utf-8

module Crass
  module Formatters
    # Converts a node or array of nodes into a CSS string. This formatter tries
    # to be as faithful to the original tokenized input as possible.
    #
    # Options:
    #
    #   * **:exclude_comments** - When `true`, comments will be excluded.
    #
    class Default
      DEFAULT_OPTIONS = {
        exclude_comments: false
      }.freeze

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.dup.merge(options)
      end

      def call(tree)
        string = String.new

        Array(tree).each do |node|
          next if node.nil?

          case node[:node]
          when :at_rule
            string << "@#{node[:name]}#{call(node[:prelude])}"
            string << (node[:block] ? "{#{call(node[:block])}}" : ';')

          when :comment
            string << node[:raw] unless @options[:exclude_comments]

          when :simple_block
            string << "#{node[:start]}#{call(node[:value])}#{node[:end]}"

          when :style_rule
            string << call(node[:selector][:tokens])
            string << "{#{call(node[:children])}}"

          else
            string << (node.key?(:raw) ? node[:raw] : call(node[:tokens]))

          end
        end

        string
      end
    end
  end
end
