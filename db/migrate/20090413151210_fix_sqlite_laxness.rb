class FixSqliteLaxness < ActiveRecord::Migration
  def self.up
    # Eliminate invalid DDL so other databases can use these tables. The
    # migrations that created these columns have been updated.
    change_column :users, :biography, :text
    change_column :proposals, :excerpt, :text
  end

  def self.down
    # Original columns had the following invalid content:
    ### change_column :users, :biography, :text, :limit => 2048
    ### change_column :proposals, :excerpt, :text, :limit => 400
  end
end
