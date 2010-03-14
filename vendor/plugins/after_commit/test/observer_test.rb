require 'test_helper'

class ObservableMockRecord < ActiveRecord::Base
  set_table_name 'mock_records'

  attr_accessor :after_commit_called
  attr_accessor :after_commit_on_create_called
  attr_accessor :after_commit_on_update_called
  attr_accessor :after_commit_on_destroy_called
end

class ObservableMockRecordObserver < ActiveRecord::Observer
  def after_commit(model)
    model.after_commit_called = true
  end

  def after_commit_on_create(model)
    model.after_commit_on_create_called = true
  end

  def after_commit_on_update(model)
    model.after_commit_on_update_called = true
  end

  def after_commit_on_destroy(model)
    model.after_commit_on_destroy_called = true
  end
end

class ObserverTest < Test::Unit::TestCase
  def setup
    ObservableMockRecord.add_observer ObservableMockRecordObserver.instance
  end

  def test_after_commit_is_called
    record = ObservableMockRecord.create!

    assert record.after_commit_called
  end

  def test_after_commit_on_create_is_called
    record = ObservableMockRecord.create!

    assert record.after_commit_on_create_called
  end

  def test_after_commit_on_update_is_called
    record = ObservableMockRecord.create!
    record.save

    assert record.after_commit_on_update_called
  end

  def test_after_commit_on_destroy_is_called
    record = ObservableMockRecord.create!.destroy

    assert record.after_commit_on_destroy_called
  end
end
