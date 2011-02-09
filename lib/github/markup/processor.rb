module GitHub
  module Markup
    class Processor
      
      @@processors = []
      @@processor_instances = []
      @@loaded = false
      @@initialized = false
      
      class << self
        def inherited(klass)
          @@processors << klass
        end

        def load_processors
          Dir.glob(File.join(File.dirname(__FILE__), 'processors', '*_processor.rb')).each { |file| require file }
          @@loaded = true
        end
        
        def init!
          @@processors.each do |proc|
            klass = proc.new
            @@processor_instances << klass
            klass.setup if klass.respond_to?(:setup)
          end
        end

        def loaded?
          @@loaded
        end
        
        def initialized?
          @@initialized
        end

        def run_callback(callback, content)
          @@processor_instances.each do |processor|
            begin
              result = processor.send(callback, content)
              content = result if result.is_a?(String)
            rescue
            end
          end
          content
        end
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
