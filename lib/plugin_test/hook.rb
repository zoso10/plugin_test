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
        env_already_set = ENV["DEPENDENCY_NEXT_OVERRIDE"]
        lockfile_changed = current_definition != @previous_lockfile

        begin
          ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
          next_lock = Pathname(File.expand_path("Gemfile_next.lock"))
          next_definition = Bundler::Definition.build(
            Pathname(File.expand_path("Gemfile")),
            next_lock,
            unlock
          )
          Bundler.ui.confirm("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          Bundler.ui.confirm(next_definition.object_id)
          Bundler.ui.confirm("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

          if lockfile_changed
            next_definition.resolve_remotely!
            next_definition.lock(next_lock)
          else
            Bundler.ui.confirm("\nNow bundling for NEXT\n")
            Bundler::Installer.new(Bundler.root, next_definition).run({})
          end
        ensure
          ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
        end
      end
    end
  end
end
