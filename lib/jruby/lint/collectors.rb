module JRuby::Lint
  class Collector
    attr_accessor :checkers, :findings

    def initialize
      @checkers  = Checker.loaded_checkers.map(&:new)
      @findings  = []
    end

    def run
      begin
        checkers.each {|c| c.check(self) }
      rescue SyntaxError => e
        file, line, message = e.message.split(/:\s*/, 3)
        findings << Finding.new(message, [:syntax, :error], file, line)
      end
    end

    def self.inherited(base)
      self.all << base
    end

    def self.all
      @collectors ||= []
    end
  end

  module ASTCollector
    attr_reader :contents

    def initialize(script = nil)
      @contents = script
      super()
    end

    def file
      '<inline-script>'
    end

    def ast
      @ast ||= JRuby.parse(contents, file, true)
    end
  end

  module FileCollector
    attr_reader :file

    def initialize(filename = nil)
      @file = filename
      super()
    end

    def contents
      @contents || File.read(@file)
    end
  end

  module Collectors
  end
end

require 'jruby/lint/collectors/ruby'
require 'jruby/lint/collectors/bundler'
require 'jruby/lint/collectors/rake'
require 'jruby/lint/collectors/gemspec'
