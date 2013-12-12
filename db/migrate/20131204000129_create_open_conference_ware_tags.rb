class CreateOpenConferenceWareTags < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_tags do |t|
      t.string "name"
    end
  end
end
