# frozen_string_literal: true

module PluginTest
  class Hook < Bundler::Plugin::API
    def setup
      self.class.hook("before-install-all") do
        @previous_lockfile = Bundler.default_lockfile.read
      end

      self.class.hook("after-install-all") do
        current_definition = Bundler.definition
        unlock = current_definition.instance_variable_get(:@unlock)

        begin
          ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
          next_definition = Bundler::Definition.build(
            Pathname(File.expand_path("Gemfile")),
            Pathname(File.expand_path("Gemfile_next.lock")),
            unlock
          )

          if current_definition.to_lock != @previous_lockfile
            next_definition.resolve_remotely!
          end

          Bundler.ui.confirm("\nNow bundling for NEXT\n")
          Bundler::Installer.new(Bundler.root, next_definition).run({})
        ensure
          ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
        end
      end
    end
  end
end
