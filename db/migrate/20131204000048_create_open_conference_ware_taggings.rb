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

    add_index "open_conference_ware_taggings", ["tag_id"]
    add_index "open_conference_ware_taggings", ["taggable_id", "taggable_type", "context"], name: "index_ocw_taggings_on_id_type_and_context"
  end
end
