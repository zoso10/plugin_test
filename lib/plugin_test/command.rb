# frozen_string_literal: true

module PluginTest
  class Command < Bundler::Plugin::API
    def setup
      self.class.command "plugin_test"
    end

    def exec(command, args)
      if args.include?("--init")
        lockfile = File.expand_path("Gemfile.lock")
        next_lockfile = File.expand_path("Gemfile_next.lock")

        if File.exists?(next_lockfile)
          Bundler.ui.warn("Gemfile_next.lock already exists. Skipping.")
        else
          begin
            ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
            FileUtils.cp(lockfile_path, next_lockfile_path)
          ensure
            ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
          end
        end
      else
        puts "You called " + command_name + " with args: " + args.inspect
      end
    end
  end
end
