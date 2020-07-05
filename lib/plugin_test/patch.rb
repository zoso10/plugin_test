# frozen_string_literal: true

module PluginTest
  module Patch
    def default_lockfile
      Pathname(File.expand_path("Gemfile_next.lock"))
    end
  end
end

Bundler::Dsl.class_eval do
  def use_next_lockfile
    if ENV["DEPENDENCY_NEXT_OVERRIDE"]
      Bundler::SharedHelpers.singleton_class.prepend(PluginTest::Patch)
    end
  end
end
