# coding: utf-8

require 'getoptlong'
require 'json'
require 'yaml'
require 'fileutils'
require 'erb'
require 'pp'

require "fr_scaffold/version"
require "fr_scaffold/layer3_helper"
require "fr_scaffold/outputter"
require "helper"

BASE_DIR = "#{File.dirname(__FILE__)}/.."
TARGET_DIR = Dir.pwd
TMP_DIR = "#{BASE_DIR}/tmp"
CONFIG_FILE = "#{TARGET_DIR}/.fr_scaffold.yml"
FR_SCAFFOLD_DIR = "#{TARGET_DIR}/fr_scaffold_files"
