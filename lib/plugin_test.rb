require "plugin_test/version"

module PluginTest
  class Error < StandardError; end

  class Command < Bundler::Plugin::API
    def setup
      self.class.command "plugin_test"
    end

    def exec(command_name, args)
      puts "You called " + command_name + " with args: " + args.inspect
    end
  end

  class Hook < Bundler::Plugin::API
    def setup
      self.class.hook("after-install-all") do
        Bundler.ui.warn("Bundling for NEXT")
        gemfile_next_path = File.expand_path("Gemfile_next.lock")
        ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
        ENV["BUNDLE_GEMFILE"] = "Gemfile_next"
        Bundler::Installer.new(Bundler.root, Bundler.definition(true)).
          run(gemfile: gemfile_next_path)
        ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
        ENV.delete("BUNDLE_GEMFILE")
      end
    end
  end
end

PluginTest::Command.new.setup
PluginTest::Hook.new.setup
