require File.dirname(__FILE__) + '/helper'

class TestOperationsOnExisting < Test::Unit::TestCase

  def setup
    copy_from       = "#{TEST_FIXTURES_DIR}/foo.git"
    @repo_path      = "#{TEST_DATA_DIR}/init.git"

    FileUtils.cp_r(copy_from, @repo_path)

    # Init Gitit and add some file
    @gitit = Gitit.new(@repo_path)
  end

  def teardown
    # Clean up the Gitit
    cleanup_dir(@repo_path)
  end

  def test_add_and_commit
    @gitit.add('foo_file.txt', 'Foo file')
    @gitit.commit('Adding foo file')

    assert_equal(true, @gitit.file_exist('foo_file.txt'))
  end

  # Check existing file modifies correclty
  def test_add_existing_file
    @gitit.add('hello.txt', 'Hello, dsyph3r')
    @gitit.commit('modifying hello world')

    file = @gitit.get_file('hello.txt')

    assert_not_nil(file)

    assert_equal('Hello, dsyph3r', file['data'], 'File data is incorrect')
  end

  def test_get_file
    file = @gitit.get_file('testing.txt')

    assert_not_nil(file)

    assert_equal('testing.txt', file['name'], 'Filename is incorrect')
    assert_equal("Test 1\nTest 2\n\nTest 4\nTest 5\n\n\nTest 6\n\nTest 8\nTest 9\n", file['data'], 'File data is incorrect')
  end

end
