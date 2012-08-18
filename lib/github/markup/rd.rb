require "English"

require "rd/rdfmt"
require "rd/rd2html-lib"

module GitHub
  module Markup
    class RD
      def initialize(content)
        @content = content
      end

      def to_html
        if /^=begin/ =~ @content
          content = @content
        else
          content = "=begin\n#{@content}\n=end\n"
        end
        tree = ::RD::RDTree.new(content)
        visitor = RD2HTMLContentOnlyVisitor.new
        visitor.visit(tree)
      end

      class RD2HTMLContentOnlyVisitor < ::RD::RD2HTMLVisitor
        def apply_to_DocumentElement(element, contents)
          body = remove_rd_label_comments(contents.join("\n"))
          [body, make_foottext].compact.join("\n") + "\n"
        end

        private
        def remove_rd_label_comments(content)
          content.gsub(/<!-- RDLabel: .+? -->/, "")
        end

        # id attribute value should match Name syntax in XML.
        # See also: http://www.w3.org/TR/REC-xml/#NT-Name
        XML_NAME_START_CHAR = /
          : |
          [A-Z] |
          _ |
          [a-z] |
          [\u00C0-\u00D6] |
          [\u00D8-\u00F6] |
          [\u00F8-\u02FF] |
          [\u0370-\u037D] |
          [\u037F-\u1FFF] |
          [\u200C-\u200D] |
          [\u2070-\u218F] |
          [\u2C00-\u2FEF] |
          [\u3001-\uD7FF] |
          [\uF900-\uFDCF] |
          [\uFDF0-\uFFFD] |
          [\u10000-\uEFFFF]
        /x
        XML_NAME_CHAR = /
          #{XML_NAME_START_CHAR} |
          - |
          \. |
          [0-9] |
          \u00B7 |
          [\u0300-\u036F] |
          [\u203F-\u2040]
        /x
        def get_anchor(element)
          label = element.label
          return super if label.nil?

          space_compressed_label = label.gsub(/ +/, "-")
          downcased_label = space_compressed_label.downcase
          return super if XML_NAME_START_CHAR !~ downcased_label

          xml_id_start_ready_label = "#{$MATCH}#{$POSTMATCH}"
          xml_id_ready_label = ""
          xml_id_start_ready_label.scan(/#{XML_NAME_CHAR}+/) do |xml_id_string|
            xml_id_ready_label << xml_id_string
          end
          meta_char_escape(xml_id_ready_label)
        end
      end
    end
  end
end
