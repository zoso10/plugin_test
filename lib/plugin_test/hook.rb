# frozen_string_literal: true

module PluginTest
  class Hook < Bundler::Plugin::API
    def setup
      self.class.hook("before-install-all") do
        @previous_lockfile = Bundler.default_lockfile.read
      end

      self.class.hook("after-install-all") do
        next if ENV["DEPENDENCY_NEXT_OVERRIDE"]

        current_definition = Bundler.definition
        unlock = current_definition.instance_variable_get(:@unlock)

        begin
          ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
          next_lock = Pathname(File.expand_path("Gemfile_next.lock"))
          next_definition = Bundler::Definition.build(
            Pathname(File.expand_path("Gemfile")),
            next_lock,
            unlock
          )

          if current_definition.to_lock != @previous_lockfile
            Bundler.ui.confirm("Now updating bundle for NEXT")
            next_definition.resolve_with_cache!
            next_definition.lock(next_lock)
          else
            Bundler.ui.confirm("Now installing bundle for NEXT")
            Bundler::Installer.new(Bundler.root, next_definition).run({})
          end
        ensure
          ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
        end
      end
    end
  end
end
