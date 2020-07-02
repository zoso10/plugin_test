require "plugin_test/version"
require "bundler"

module PluginTest
  class Error < StandardError; end

  class Command < Bundler::Plugin::API
    command "plugin_test"

    def exec(command_name, args)
      puts "You called " + command_name + " with args: " + args.inspect
    end
  end
end
