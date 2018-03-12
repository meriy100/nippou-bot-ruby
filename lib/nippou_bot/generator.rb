require 'erb'

module NippouBot
  class Generator
    attr_accessor :file
    def self.generate(reports = {})
      template = File.read("./templates/template.md.erb")
      erb = ERB.new(template, 0, '%-')
      result(erb, reports)
    end

    def self.result(erb, reports)
      erb.result(binding)
    end
  end
end
