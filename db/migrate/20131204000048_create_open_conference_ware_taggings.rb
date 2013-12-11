class CreateOpenConferenceWareTaggings < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_taggings do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "open_conference_ware_taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    add_index "open_conference_ware_taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end
end
