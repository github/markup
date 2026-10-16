require "asciidoctor"
require "asciidoctor/converter/html5"

module GitHub
  module Markup
    # HTML5 converter that renders admonitions (NOTE, TIP, IMPORTANT, WARNING,
    # CAUTION) with the same markup as Markdown alerts, so they pick up the
    # styles GitHub already ships for those. Every other node is converted by
    # the built-in Asciidoctor HTML5 converter.
    #
    # The class is passed to Asciidoctor through the :converter option rather
    # than registered for the html5 backend, so other Asciidoctor conversions
    # in the same process are not affected.
    class AsciidoctorConverter < ::Asciidoctor::Converter::Html5Converter
      def convert_admonition(node)
        id_attr = node.id ? %( id="#{node.id}") : ''
        name = node.attr 'name'
        role = node.role ? " #{node.role}" : ''
        # Like a Markdown alert with a custom title, the block title replaces the label.
        title = node.title? ? node.title : (node.attr 'textlabel')
        content = node.content_model == :compound ? node.content : %(<p>#{node.content}</p>)
        %(<div#{id_attr} class="markdown-alert markdown-alert-#{name}#{role}">
<p class="markdown-alert-title">#{title}</p>
#{content}
</div>)
      end
    end
  end
end
