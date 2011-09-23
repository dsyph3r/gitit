require File.dirname(__FILE__) + '/helper'

class TestRemoteOperations < Test::Unit::TestCase

  def setup
    @init_repo_path  = "#{TEST_DATA_DIR}/init.git"
    @fork_repo_path  = "#{TEST_DATA_DIR}/fork.git"

    # Init Gitit and add some file
    @init_gitit = Gitit.new(@init_repo_path)
    @init_gitit.add('testing1.txt', 'Test file 1')
    @init_gitit.commit('Adding test file 1')

    @init_gitit.add('testing2.txt', 'Test file 2')
    @init_gitit.commit('Adding test file 2')

    @init_gitit.add('testing3.txt', 'Test file 3')
    @init_gitit.commit('Adding test file 3')

    #@fork_gitit = Gitit.clone(@init_repo_path, @fork_repo_path)
    @fork_gitit = @init_gitit.fork(@fork_repo_path)
  end

  def teardown
    # Clean up the Gitit
    cleanup_dir(@init_repo_path)
    cleanup_dir(@fork_repo_path)
  end

  def test_pull
    # Add some files to init Gitit
    @init_gitit.add('pull_me.txt', 'Pull Me')
    @init_gitit.commit('Adding file to be pulled')
  
    # Pull changes into fork
    @fork_gitit.pull(@init_repo_path, TEST_DATA_DIR)
  
    assert_equal(true, @fork_gitit.file_exist('pull_me.txt'))
  
    file = @fork_gitit.get_file('pull_me.txt')
    assert_equal('pull_me.txt', file['name'], 'Filename is incorrect')
    assert_equal('Pull Me', file['data'], 'File data is incorrect')
  end

  def test_push
    # Add some files to forked Gitit
    @fork_gitit.add('push_me.txt', 'Push Me')
    @fork_gitit.commit('Adding file to be pushed')

    puts @fork_gitit.file_exist('push_me.txt')
    # Push changes back to init Gitit
    @fork_gitit.push(@init_repo_path)

    assert_equal(true, @init_gitit.file_exist('push_me.txt'))
  end

end
