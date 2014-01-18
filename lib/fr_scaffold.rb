# coding: utf-8

require 'getoptlong'
require 'json'
require 'fileutils'

require "fr_scaffold/version"
require "fr_scaffold/parser"
require "fr_scaffold/main"
require "helper"

BASE_DIR = "#{File.dirname(__FILE__)}/.."
TARGET_DIR = Dir.pwd
TMP_DIR = "#{BASE_DIR}/tmp"
