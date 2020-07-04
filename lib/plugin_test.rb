# frozen_string_literal: true

require "bundler"
require "fileutils"
require "pathname"

require "plugin_test/command"
require "plugin_test/hook"
require "plugin_test/version"

PluginTest::Command.new.setup
PluginTest::Hook.new.setup
