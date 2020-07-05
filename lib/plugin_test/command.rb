# frozen_string_literal: true

module PluginTest
  class Command < Bundler::Plugin::API
    def configure
      self.class.command "plugin_test"
    end

    def exec(command, args)
      if args.include?("--init")
        lockfile_path = File.expand_path("Gemfile.lock")
        next_lockfile_path = File.expand_path("Gemfile_next.lock")

        if File.exists?(next_lockfile_path)
          Bundler.ui.warn("Gemfile_next.lock already exists. Skipping.")
        else
          FileUtils.cp(lockfile_path, next_lockfile_path)
        end
      else
        puts "You called " + command_name + " with args: " + args.inspect
      end
    end
  end
end
