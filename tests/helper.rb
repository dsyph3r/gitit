require 'test/unit'

require 'rubygems'
require 'bundler/setup'
require 'grit'
require 'fileutils'

require File.dirname(__FILE__) + '/../lib/gitit.rb'

# Set path for testing directorys
TEST_DATA_DIR     = "#{Dir.pwd}/data"
TEST_FIXTURES_DIR = "#{Dir.pwd}/fixtures"

def cleanup_dir(path)
  if File.directory?(path)
    FileUtils.rm_r path
  end
end

def create_dir_not_exist(path)
  if !File.directory?(path)
    Dir.mkdir(path)
  end
end

# Setup the testing directory
create_dir_not_exist(TEST_DATA_DIR)
