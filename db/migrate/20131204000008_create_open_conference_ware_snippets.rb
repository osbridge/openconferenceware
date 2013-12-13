class CreateOpenConferenceWareSnippets < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_snippets do |t|
      t.string   "slug",                       null: false
      t.text     "description",                null: false
      t.text     "content"
      t.integer  "value"
      t.boolean  "public",      default: true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "open_conference_ware_snippets", ["slug"], unique: true
  end
end
