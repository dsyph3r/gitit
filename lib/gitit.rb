require 'rubygems'
require 'bundler/setup'
require 'grit'
require 'fileutils'

# Gitit - Provides read/write access to a git repository.
#
# Provides an interface to grit with extended functionality
# not present in grit (such as external repository action - push/pull/etc)
class Gitit
  # Repository location
  attr_reader :location
  attr_reader :branch

  # Initialize - Creates or loads a repository from disk
  # location must be write accessible
  def initialize(location)
    @location = location
    @branch   = 'master'

    if !File.directory?(@location)
      Grit::Repo.init_bare(@location)
    end

    begin
      # Get existing repo
      @repo  = Grit::Repo.new(@location)
    rescue
      raise
    end

    # Get the index tree (the staging area)
    @index = @repo.index
    # Pre-populate the tree with master (ie set the starting point and then add to it)
    @index.read_tree(@branch)
    # Save the first commit - we use this to set the parent for the next commit
    @parent = @repo.commits.first
  end
  
end
