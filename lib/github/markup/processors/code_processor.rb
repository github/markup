require "albino"
require 'digest/sha1'
require 'cgi'

module GitHub
  module Markup
    class Albino < ::Albino
      self.bin              = ::Albino.bin
      self.default_encoding = ::Albino.default_encoding

      def colorize(options = {})
        html = super.to_s
        html.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")
        html
      end
    end
    
    class CodeProcessor < GitHub::Markup::Processor
      
      def before_render(content)
        extract_code(content)
      end
      
      def after_render(content)
        process_code(content)
      end
      
      # Extract all code blocks into the codemap and replace with placeholders.
      #
      # data - The raw String data.
      #
      # Returns the placeholder'd String data.
      def extract_code(data)
        @codemap ||= {}
        data.gsub!(/^``` ?([^\r\n]+)?\r?\n(.+?)\r?\n```\r?$/m) do
          id     = Digest::SHA1.hexdigest($2)
          cached = check_cache(:code, id)
          @codemap[id] = cached   ?
            { :output => cached } :
            { :lang => $1, :code => $2 }
          id
        end
        
        data
      end

      # Process all code from the codemap and replace the placeholders with the
      # final HTML.
      #
      # data - The String data (with placeholders).
      #
      # Returns the marked up String data.
      def process_code(data)
        @codemap.each do |id, spec|
          formatted = spec[:output] || begin
            code = spec[:code]
            lang = spec[:lang]

            if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(  |\t)/ }
              code.gsub!(/^(  |\t)/m, '')
            end
            
            formatted = begin
              lang && Markup::Albino.colorize(code, lang)
            rescue ::Albino::ShellArgumentError, ::Albino::Process::TimeoutExceeded, ::Albino::Process::MaximumOutputExceeded
            end
            
            formatted ||= "<pre><code>#{CGI.escapeHTML(code)}</code></pre>"
            update_cache(:code, id, formatted)
            
            # Ensure we always return something, if formatting fails just return the original code
            formatted.empty? && !code.empty? ? code : formatted
          end
          data.gsub!(id, formatted)
        end
        data
      end
      
      # Hook for getting the formatted value of extracted tag data.
      #
      # type - Symbol value identifying what type of data is being extracted.
      # id   - String SHA1 hash of original extracted tag data.
      #
      # Returns the String cached formatted data, or nil.
      def check_cache(type, id)
      end

      # Hook for caching the formatted value of extracted tag data.
      #
      # type - Symbol value identifying what type of data is being extracted.
      # id   - String SHA1 hash of original extracted tag data.
      # data - The String formatted value to be cached.
      #
      # Returns nothing.
      def update_cache(type, id, data)
      end
      
    end
  end
end