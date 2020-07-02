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
        if $bad != 1
          Bundler.ui.warn("Bundling for NEXT")
          gemfile_next_path = File.expand_path("Gemfile_next.lock")
          Bundler::CLI::Install.new(gemfile: gemfile_next_path).run
          $bad = 1
        end
      end
    end
  end
end

PluginTest::Command.new.setup
PluginTest::Hook.new.setup
