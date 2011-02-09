

begin
  require 'open3_detach'
rescue LoadError
  require 'open3'
end

$:.unshift(File.dirname(__FILE__))

module GitHub
  module Markup
    
    autoload :Processor, "markup/processor"
    
    extend self
    @@markups = {}

    def render(filename, content = nil)
      content ||= File.read(filename)
      
      @codemap ||= {}
      content = extract_code(content)
      
      if proc = renderer(filename)
        proc[content]
      else
        content
      end
      
      content = process_code(content)
      
      content
    end

    def markup(file, pattern, &block)
      require file.to_s
      add_markup(pattern, &block)
    rescue LoadError
      nil
    end

    def command(command, regexp, &block)
      command = command.to_s

      if File.exists?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      add_markup(regexp) do |content|
        rendered = execute(command, content)
        rendered = rendered.to_s.empty? ? content : rendered

        if block && block.arity == 2
          # If the block takes two arguments, pass new content and old
          # content.
          block.call(rendered, content)
        elsif block
          # One argument is just the new content.
          block.call(rendered)
        else
          # No block? No problem!
          rendered
        end
      end
    end

    def add_markup(regexp, &block)
      @@markups[regexp] = block
    end

    def can_render?(filename)
      !!renderer(filename)
    end

    def renderer(filename)
      @@markups.each do |key, value|
        if Regexp.compile("\\.(#{key})$") =~ filename
          return value
        end
      end
      nil
    end

    def execute(command, target)
      out = ''
      Open3.popen3(command) do |stdin, stdout, _|
        stdin.puts target
        stdin.close
        out = stdout.read
      end
      out.gsub("\r", '')
    rescue Errno::EPIPE
      ""
    end
    
    #########################################################################
    #
    # Code
    #
    #########################################################################

    # Extract all code blocks into the codemap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_code(data)
      data.gsub!(/^``` ?([^\r\n]+)?\r?\n(.+?)\r?\n```\r?$/m) do
        id     = Digest::SHA1.hexdigest($2)
        cached = nil #check_cache(:code, id)
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
            lang && Albino.colorize(code, lang)
          rescue ::Albino::ShellArgumentError, ::Albino::Process::TimeoutExceeded,
              ::Albino::Process::MaximumOutputExceeded
          end
          formatted ||= "<pre><code>#{CGI.escapeHTML(code)}</code></pre>"
          # update_cache(:code, id, formatted)
          formatted
        end
        data.gsub!(id, formatted)
      end
      data
    end

    # Define markups
    instance_eval File.read(File.dirname(__FILE__) + '/markups.rb')
  end
end
