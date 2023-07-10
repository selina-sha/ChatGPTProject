class ReCreateUserModel < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :description
      t.string :career

      t.timestamps
    end
  end
end