require File.dirname(__FILE__) + '/helper'

class TestFork < Test::Unit::TestCase

  def setup
    # Create a Gitit to fork
    @repo_path = "#{TEST_DATA_DIR}/test.git"
    @gitit = Gitit.new(@repo_path)
  end

  def teardown
    # Clean up the Gitit
    cleanup_dir(@repo_path)
  end

  # Check fork is successful
  def test_fork_repo
    fork_to_path = "#{TEST_DATA_DIR}/fork.git"

    assert_nothing_raised do
      @gitit.fork(fork_to_path)
    end

    assert(File.exist?("#{fork_to_path}/HEAD"), "Checking HEAD file exists at #{fork_to_path}")

    cleanup_dir(fork_to_path)
  end

  # Checks fork fails when trying to fork to an existing directory
  def test_fork_to_existing_directory
    fork_to_path = "#{TEST_DATA_DIR}/fork.git"

    # Create an empty dir where we want to clone a new Gitit to
    create_dir_not_exist(fork_to_path)

    # Try the clone
    assert_raise RuntimeError do
      @gitit.fork(fork_to_path)
    end

    cleanup_dir(fork_to_path)
  end

end
