require File.dirname(__FILE__) + '/helper'

class TestClone < Test::Unit::TestCase
  
  def setup
    # Create a Gitit to clone
    @repo_path  = "#{TEST_DATA_DIR}/test.git"
    gitit       = Gitit.new(@repo_path)
  end

  def teardown
    # Clean up the Gitit
    cleanup_dir(@repo_path)
  end

  # Check clone is successful
  def test_clone_repo
    clone_to_path = "#{TEST_DATA_DIR}/clone.git"
  
    assert_nothing_raised RuntimeError do
      Gitit.clone(@repo_path, clone_to_path)
    end
  
    assert(File.exist?("#{clone_to_path}/HEAD"), "Checking HEAD file exists at #{clone_to_path}")
  
    cleanup_dir(clone_to_path)
  end

  # Checks clone fails when trying to clone to an existing directory
  def test_clone_to_existing_directory
    clone_to_path = "#{TEST_DATA_DIR}/clone.git"

    # Create an empty dir where we want to clone a new Gitit to
    create_dir_not_exist(clone_to_path)

    # Try the clone
    assert_raise RuntimeError do
      Gitit.clone(@repo_path, clone_to_path)
    end

    cleanup_dir(clone_to_path)
  end
  
end
