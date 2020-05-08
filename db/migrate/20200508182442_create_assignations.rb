class CreateAssignations < ActiveRecord::Migration[5.2]
  def change
    create_table :assignations, id: :integer, if_not_exists: true do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.float :hour_rate
      t.text :comment
      t.integer :hours_assigned

      t.integer :project_id
      t.integer :user_id
    end
    add_index :assignations, :project_id unless index_exists?(:assignations, :project_id)
    add_index :assignations, :user_id unless index_exists?(:assignations, :user_id)
  end
end
