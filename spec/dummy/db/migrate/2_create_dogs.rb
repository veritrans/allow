class CreateDogs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :dogs do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :dogs
  end
end
