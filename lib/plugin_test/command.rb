# frozen_string_literal: true

module PluginTest
  class Command < Bundler::Plugin::API
    module Patch
      def specs
        super.merge(next_specs)
      end

      def next_specs
        ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"
        deps = if Bundler.settings[:cache_all_platforms]
                 dependencies
               else
                 requested_dependencies
               end
        next_specs = Bundler::Definition.
          build(Pathname("Gemfile"), Pathname("Gemfile_next.lock"), nil).
          resolve.
          materialize(deps)
      ensure
        ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
      end
    end

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
      elsif args.include?("clean")
        Bundler.io.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        Bundler.io.info(args.inspect)
        Bundler.io.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        require "bundler/cli"
        require "bundler/cli/clean"

        Bundler::Definition.prepend(PluginTest::Command::Patch)

        options = {
          "dry-run" => args.include?("--dry-run"),
          "force" => args.include?("--force"),
        }
        Bundler::CLI::Clean.new(options).run
      else
        puts "You called " + command_name + " with args: " + args.inspect
      end
    end
  end
end
