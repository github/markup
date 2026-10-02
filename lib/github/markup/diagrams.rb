require "base64"
require "tmpdir"

module GitHub
  module Markup
    # Renders AsciiDoc diagram blocks -- PlantUML, C4, Mermaid, Graphviz, ... --
    # as images, using the optional asciidoctor-diagram gem.
    #
    # When that gem is installed, a diagram block is rendered locally and inlined
    # as a data URI. When it is not -- or when the toolchain a diagram type needs
    # is missing -- the block falls back to a source block tagged with the diagram
    # language (`<pre lang="plantuml">`), so a client-side renderer can still pick
    # it up instead of degrading to an untagged <pre>.
    #
    # Nothing is enabled by default, so a plain install never depends on a diagram
    # toolchain.
    module Diagrams
      # Diagram types recognised as AsciiDoc block styles, mapped to the
      # asciidoctor-diagram extension that renders them.
      LOCAL_EXTENSIONS = {
        "bpmn"        => ["asciidoctor-diagram/bpmn/extension",        "BpmnBlockProcessor"],
        "bytefield"   => ["asciidoctor-diagram/bytefield/extension",   "BytefieldBlockProcessor"],
        "d2"          => ["asciidoctor-diagram/d2/extension",          "D2BlockProcessor"],
        "dbml"        => ["asciidoctor-diagram/dbml/extension",        "DbmlBlockProcessor"],
        "ditaa"       => ["asciidoctor-diagram/ditaa/extension",       "DitaaBlockProcessor"],
        "erd"         => ["asciidoctor-diagram/erd/extension",         "ErdBlockProcessor"],
        "graphviz"    => ["asciidoctor-diagram/graphviz/extension",    "GraphvizBlockProcessor"],
        "mermaid"     => ["asciidoctor-diagram/mermaid/extension",     "MermaidBlockProcessor"],
        "nomnoml"     => ["asciidoctor-diagram/nomnoml/extension",     "NomnomlBlockProcessor"],
        "pikchr"      => ["asciidoctor-diagram/pikchr/extension",      "PikchrBlockProcessor"],
        "plantuml"    => ["asciidoctor-diagram/plantuml/extension",    "PlantUmlBlockProcessor"],
        "structurizr" => ["asciidoctor-diagram/structurizr/extension", "StructurizrBlockProcessor"],
        "wavedrom"    => ["asciidoctor-diagram/wavedrom/extension",    "WavedromBlockProcessor"]
      }.freeze

      DIAGRAM_TYPES = LOCAL_EXTENSIONS.keys.freeze

      DEFAULT_FORMAT = "svg".freeze

      FORMATS = %w[svg png].freeze

      MIME_TYPES = {"svg" => "image/svg+xml", "png" => "image/png"}.freeze

      # Wraps Asciidoctor.convert, adding the diagram block extensions.
      #
      # When rendering is possible the conversion is handed a scratch directory as
      # its base dir. asciidoctor-diagram writes generated images to disk, and
      # under safe mode :secure Asciidoctor confines those writes to the base dir;
      # pointing the base dir at a scratch directory keeps them out of the caller's
      # working directory. The images are inlined as data URIs and the directory is
      # thrown away, so rendering stays string-in, string-out.
      def self.convert(content, options)
        options = options.merge(:extension_registry => extension_registry)
        return ::Asciidoctor.convert(content, options) unless local_rendering_installed?

        Dir.mktmpdir("github-markup-diagram") do |dir|
          ::Asciidoctor.convert(content, options.merge(
            :base_dir => dir,
            :attributes => options[:attributes].merge("imagesoutdir" => dir)
          ))
        end
      end

      # Whether the optional asciidoctor-diagram gem is available. Checked against
      # the gem index rather than by requiring it, so that merely rendering an
      # AsciiDoc file does not pay for loading it.
      def self.local_rendering_installed?
        return @local_rendering_installed if defined?(@local_rendering_installed)

        @local_rendering_installed = begin
          Gem::Specification.find_by_name("asciidoctor-diagram")
          true
        rescue Gem::LoadError
          false
        end
      end

      # An Asciidoctor extension registry holding a block processor for every
      # supported diagram type.
      #
      # The registry is deliberately not registered globally. Asciidoctor's global
      # extension registry is process-wide state, and this library must not change
      # how unrelated code converts documents -- which is also why the individual
      # `asciidoctor-diagram/<type>/extension` files are required below rather than
      # `asciidoctor-diagram` itself, whose top level registers 37 extension groups
      # globally as a side effect.
      def self.extension_registry
        ::Asciidoctor::Extensions.create do
          DIAGRAM_TYPES.each { |type| block ::GitHub::Markup::Diagrams.block_processor, type }
        end
      end

      def self.block_processor
        @block_processor ||= build_block_processor
      end

      def self.local_processor_for(diagram_type)
        return nil unless local_rendering_installed?

        @local_processors ||= {}
        return @local_processors[diagram_type] if @local_processors.key?(diagram_type)

        @local_processors[diagram_type] = load_local_processor(diagram_type)
      end

      def self.load_local_processor(diagram_type)
        path, class_name = LOCAL_EXTENSIONS.fetch(diagram_type)
        require path
        ::Asciidoctor::Diagram.const_get(class_name).new(diagram_type.to_sym, {})
      rescue LoadError
        nil
      end

      def self.build_block_processor
        Class.new(::Asciidoctor::Extensions::BlockProcessor) do
          use_dsl
          on_contexts :listing, :literal, :open
          name_positional_attributes "style", "format"

          def process(parent, reader, attrs)
            diagram_type = @name.to_s
            lines = reader.readlines

            image_block(parent, attrs, diagram_type, lines) ||
              source_block(parent, attrs, diagram_type, lines)
          end

          private

          # Renders with asciidoctor-diagram and inlines the generated image as a
          # data URI, so the returned HTML does not depend on where the file
          # landed. Returns nil when the diagram cannot be rendered -- the gem is
          # absent, or its toolchain is missing -- leaving the caller to fall back.
          #
          # asciidoctor-diagram reports a failed render by handing back a listing
          # block containing the error rather than by raising, hence the check on
          # the returned block's context.
          def image_block(parent, attrs, diagram_type, lines)
            processor = Diagrams.local_processor_for(diagram_type)
            return nil unless processor

            format = format_for(attrs)
            block = processor.process(
              parent,
              ::Asciidoctor::Reader.new(lines),
              # 'data-uri' is passed per block, never as a document attribute:
              # asciidoctor-diagram reads it to decide to report an absolute path,
              # which is what we need to find the file, while setting it on the
              # document would also make Asciidoctor try to inline every ordinary
              # image:: in the file.
              attrs.merge("data-uri" => "", "format" => format)
            )
            return nil unless block.context == :image

            data_uri = data_uri_for(block.attr("target"), format)
            return nil unless data_uri

            create_image_block(parent, attrs.merge(
              "style" => "image",
              "target" => data_uri,
              "alt" => attrs.fetch("alt", "#{diagram_type} diagram"),
              "role" => [attrs["role"], "diagram", diagram_type].compact.join(" ")
            ))
          end

          def data_uri_for(path, format)
            return nil unless File.file?(path.to_s)

            "data:#{Diagrams::MIME_TYPES.fetch(format)};base64," +
              Base64.strict_encode64(File.binread(path))
          end

          # The fallback. Emitting the diagram source as a source block keeps the
          # language in the HTML (`<pre lang="plantuml">`) so a client-side
          # renderer can pick it up, instead of degrading to an untagged <pre>.
          def source_block(parent, attrs, diagram_type, lines)
            create_block(parent, :listing, lines, attrs.merge(
              "style" => "source",
              "language" => diagram_type
            ), :content_model => :verbatim)
          end

          def format_for(attrs)
            format = attrs["format"]
            Diagrams::FORMATS.include?(format) ? format : Diagrams::DEFAULT_FORMAT
          end
        end
      end
    end
  end
end
