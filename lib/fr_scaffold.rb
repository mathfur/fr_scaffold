# encoding: utf-8

require 'getoptlong'
require 'fileutils'

require "fr_scaffold/version"
require "fr_scaffold/helper"
require "fr_scaffold/parser"

BASE_DIR = "#{File.dirname(__FILE__)}/.."
TARGET_DIR = Dir.pwd
