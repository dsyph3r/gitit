require 'rubygems'
require 'bundler/setup'
require 'grit'
require 'fileutils'
require 'digest/sha1'

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
  
  # Push - Push changes to remote repository
  def push(push_path)
    rgit = Grit::Git.new(@location)
    opts = {
      :repo       => push_path,
      :verbose    => true,
      :progress   => true,
    }
    puts push_path
    rgit.push(opts)
  end

  def fetch()

  end

  def merge()

  end

  # Pull - Pull changes in from remote repository
  # As pull is just a fetch and a merge, should this use the above methods
  # instead of raw git calls?
  def pull(pull_path, work_tree_dir)

    # Cannot pull into a repository that doesn't have a working copy. We need to
    # create a temp working copy else where on disk
    work_tree_path = "#{work_tree_dir}/#{Digest::SHA1.hexdigest(pull_path)}"

    # Create temp working directoy
    Dir.mkdir(work_tree_path)

    # Cannot use grit for pull - need to use raw git calls
    Dir.chdir(work_tree_path) do
      # We cannot use Grit to do this. There is a bug in the lib that doesn't correctly
      # set the work_tree path. A pull request has been submitted
      # https://github.com/mojombo/grit/pull/43 but its from Nov 2010. May
      # need to implement this ourself
      #rgit = Grit::Git.new(".")
      #opts = {
      #  :git_dir     => full_path,
      #  :work_tree   => work_tree_path
      #}
      #puts rgit.pull(opts, pull_path)

      # Doing a raw shell call instead
      `git --git-dir="#{@location}" --work-tree="#{work_tree_path}" pull -q`
    end

    FileUtils.rm_r work_tree_path
  end

end
