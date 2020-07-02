require "plugin_test/version"
require "pathname"

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
        begin
          ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
          definition = Bundler::Definition.build(
            Pathname(File.expand_path("Gemfile")),
            Pathname(File.expand_path("Gemfile_next.lock")),
            {}
          )
          Bundler::Installer.new(Bundler.root, definition).run({})
        ensure
          ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
        end
      end
    end
  end
end

PluginTest::Command.new.setup
PluginTest::Hook.new.setup
