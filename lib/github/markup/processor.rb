module GitHub
  module Markup
    class Processor
      
      @@processors = []
      @@loaded = false
      
      def self.inherited(klass)
        instance = klass.new
        @@processors << instance
      end
      
      def self.load
        Dir.glob(File.join(File.dirname(__FILE__), 'processors', '*_processor.rb')).each { |file| require file }
        @@loaded = true
      end
      
      def self.loaded?
        @@loaded
      end
      
      def self.run_callback(callback, content)
        @@processors.each do |processor|
          begin
            result = processor.send(callback, content)
            content = result if result.is_a?(String)
          rescue
          end
        end
        content
      end
      
      def initialize
        self.setup
      end
      
      def setup
        # noop
      end
      
      def before_render(content)
        # noop
      end
      
      def after_render(content)
        # noop
      end
      
    end
  end
end
