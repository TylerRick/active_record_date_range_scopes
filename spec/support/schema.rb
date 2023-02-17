ActiveRecord::Schema.define do
  # In order to avoid duplication, and to ensure that the template migration is valid, the schema for :addresses table can be found in lib/generators/address_concern/templates/migration.rb

  create_table :books, force: true do |t|
    t.string   :name
    t.belongs_to :author
    t.timestamps
  end

  create_table :authors, force: true do |t|
    t.string   :name
    t.timestamps
  end
end
