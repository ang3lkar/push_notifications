class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :title
      t.string :text
      t.string :notification_id

      t.timestamps
    end
  end
end
