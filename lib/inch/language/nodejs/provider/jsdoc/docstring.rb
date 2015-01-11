
module Inch
  module Language
    module Nodejs
      module Provider
        module JSDoc
          class Docstring < Ruby::Provider::YARD::Docstring
            VISIBILITIES = %w(public protected private)

            def initialize(text)
              @text = without_comment_markers(text)
            end

            def describes_internal_api?
              tag?(:api, :private) || super
            end

            def describes_parameter?(name)
              return false if name.nil?
              parameter = parameter_notations(name)
              tag?(:param, /#{parameter}\s+\S+/)
            end

            def mentions_parameter?(name)
              return false if name.nil?
              parameter = parameter_notations(name)
              tag?(:param, /#{parameter}/) || super
            end

            def mentions_return?
              tag?(:return) || super
            end

            def describes_return?
              type_notation = /(\{[^\}]+\}|\[[^\]]+\])/
              tag?(:return, /#{type_notation}*(\s\w+)/) || super
            end

            # @param access_value [nil,String] visibility in JSDoc output
            def visibility(access_value = nil)
              tagged_value = VISIBILITIES.detect do |v|
                tag?(v)
              end
              (tagged_value || access_value || 'public').to_sym
            end

            def tag?(tagname, regex = nil)
              if @text =~ /^\s*\@#{tagname}([^\n]*)$/m
                if regex.nil?
                  true
                else
                  $1 =~ /#{regex}/
                end
              end
            end

            private

            # Removes the comment markers // /* */ from the docstring.
            #
            #   Docstring.new("// test").without_comment_markers
            #   # => "test"
            #
            # @return [String]
            def without_comment_markers(text)
              text.to_s.lines.map do |line|
                line.strip.gsub(/^(\s*(\/\*+|\/\/|\*+\/|\*)+\s?)/m, '')
              end.join("\n").strip
            end
          end
        end
      end
    end
  end
end
