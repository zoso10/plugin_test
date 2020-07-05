# frozen_string_literal: true

require "bundler"
require "fileutils"
require "pathname"

require "plugin_test/command"
require "plugin_test/hook"
require "plugin_test/patch"
require "plugin_test/version"

PluginTest::Command.new.configure
PluginTest::Hook.new.configure
