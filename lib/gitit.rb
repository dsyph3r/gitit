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
      @repo = Grit::Repo.new(@location)
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
  
  # Clone - Create a new Gitit by cloning an existing repository
  def self.clone(clone_from, clone_to)
    if File.directory?(clone_to)
      raise "GititException: Directory #{clone_to} already exists. Cannot clone repository."
    end

    # Cannot use grit for clone - need to use raw git calls
    rgit = Grit::Git.new(clone_to)
    opts = {
      :quiet      => false,
      :verbose    => true,
      :progress   => true,
      :branch     => 'master',
      :bare       => true
    }
    rgit.clone(opts, clone_from, clone_to)

    self.new(clone_to)
  end
  
  # Fork - Forks an existing repository
  def fork(fork_path)
    if File.directory?(fork_path)
      raise "GititException: Directory #{fork_path} already exists. Cannot fork repository."
      return
    end

    forked = @repo.fork_bare(fork_path)

    return Gitit.new(fork_path)
  end
  
  # Add - Add a file to the index
  def add(path, data)
    # TODO: check for invalid paths
    @index.add(path, data)

    return true
  end

  # Commit - Commit the index to the repo
  def commit(message, author = nil)
    # Check for parrent
    if @parent.nil?
      @parent = @index.commit(message, nil, author)
    else
      # Parent of commit can be multiple, hence array for 2nd arg
      @parent = @index.commit(message, [@parent], author)
    end
  end

  # Get File - Gets a file by path. Returns hash containing file information
  def get_file(path)
    if (!file_exist(path))
      return false
    else
      raw = @repo.tree/path    # Current tree

      file = {}
      file['name'] = raw.name
      file['data'] = raw.data
      file['size'] = raw.size

      return file
    end
  end

  # File Exists - Check if a file at path exists
  def file_exist(path)
    raw = @repo.tree/path     # Current tree

    return raw.nil? ? false : true
  end

  # Revisions - Get revision from current branch
  def revisions(start, depth = 10)
    commits = @repo.commits(@branch, depth)

    revisions = []
    commits.each do |c|
      revisions.push(c.to_hash)
    end

    return revisions
  end
  
end
