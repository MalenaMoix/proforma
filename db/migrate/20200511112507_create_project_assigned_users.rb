class CreateProjectAssignedUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_assigned_users, id: :integer do |t|
      t.date :start_date
      t.date :end_date
      t.float :hour_rate
      t.text :comment
      t.integer :assigned_hours

      t.references :project, type: :integer, foreign_key: true
      t.references :user, type: :integer, foreign_key: true
    end
  end
end
