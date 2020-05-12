class Project < ActiveRecord::Base

    # Tengo que decirle a Project como usar la tabla project_assigned_users
    has_many :project_assigned_users

    # Para llegar a los users tengo que atravesar la tabla project_assigned_users
    has_many :users, through: :project_assigned_users

end