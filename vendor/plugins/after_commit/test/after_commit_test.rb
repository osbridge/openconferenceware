require 'test_helper'

class MockRecord < ActiveRecord::Base
  attr_accessor :before_commit_on_create_called
  attr_accessor :before_commit_on_update_called
  attr_accessor :before_commit_on_destroy_called
  attr_accessor :after_commit_on_create_called
  attr_accessor :after_commit_on_update_called
  attr_accessor :after_commit_on_destroy_called

  before_commit_on_create :do_before_create
  def do_before_create
    self.before_commit_on_create_called = true
  end

  before_commit_on_update :do_before_update
  def do_before_update
    self.before_commit_on_update_called = true
  end

  before_commit_on_create :do_before_destroy
  def do_before_destroy
    self.before_commit_on_destroy_called = true
  end

  after_commit_on_create :do_after_create
  def do_after_create
    self.after_commit_on_create_called = true
  end

  after_commit_on_update :do_after_update
  def do_after_update
    self.after_commit_on_update_called = true
  end

  after_commit_on_create :do_after_destroy
  def do_after_destroy
    self.after_commit_on_destroy_called = true
  end
end

class Foo < ActiveRecord::Base
  attr_reader :creating

  after_commit :create_bar

  private

  def create_bar
    @creating ||= 0
    @creating += 1

    raise Exception, 'looping' if @creating > 1
    Bar.create
  end
end

class Bar < ActiveRecord::Base
  #
end

class UnsavableRecord < ActiveRecord::Base
  attr_accessor :after_commit_called

  set_table_name 'mock_records'

  protected

  def after_initialize
    self.after_commit_called = false
  end

  def after_save
    raise
  end

  after_commit :after_commit

  def after_commit
    self.after_commit_called = true
  end
end

class AfterCommitTest < Test::Unit::TestCase
  def test_before_commit_on_create_is_called
    assert_equal true, MockRecord.create!.before_commit_on_create_called
  end

  def test_before_commit_on_update_is_called
    record = MockRecord.create!
    record.save
    assert_equal true, record.before_commit_on_update_called
  end

  def test_before_commit_on_destroy_is_called
    assert_equal true, MockRecord.create!.destroy.before_commit_on_destroy_called
  end

  def test_after_commit_on_create_is_called
    assert_equal true, MockRecord.create!.after_commit_on_create_called
  end

  def test_after_commit_on_update_is_called
    record = MockRecord.create!
    record.save
    assert_equal true, record.after_commit_on_update_called
  end

  def test_after_commit_on_destroy_is_called
    assert_equal true, MockRecord.create!.destroy.after_commit_on_destroy_called
  end

  def test_after_commit_does_not_trigger_when_transaction_rolls_back
    record = UnsavableRecord.new
    begin; record.save; rescue; end

    assert_equal false, record.after_commit_called
  end

  def test_two_transactions_are_separate
    Bar.delete_all
    foo = Foo.create

    assert_equal 1, foo.creating
  end
end
