require File.dirname(__FILE__) + '/helper'

class TestCreation < Test::Unit::TestCase
  
  # Check non existant Gitit initialise correctly, and then reloads
  def test_init_repo
    repo_path = "#{TEST_DATA_DIR}/init.git"
    
    # Create new Gitit
    assert_nothing_raised Exception do
      gitit = Gitit.new(repo_path)
    end
    assert(File.exist?("#{repo_path}/HEAD"), "Checking HEAD file exists at #{repo_path}")
    
    # Reload existing Gitit
    assert_nothing_raised Exception do
      gitit = Gitit.new(repo_path)
    end
    
    cleanup_dir(repo_path)
  end
  
  # Check Gitit fails to create when non git directory already exists
  def test_init_repo_already_exists
    repo_path = "#{TEST_DATA_DIR}/test"
    
    # Create an empty dir where we want to create a new Gitit
    create_dir_not_exist(repo_path)
    
    assert_raise Grit::InvalidGitRepositoryError do
      gitit = Gitit.new(repo_path)
    end
    
    cleanup_dir(repo_path)
  end
  
end