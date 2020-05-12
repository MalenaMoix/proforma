class User < ActiveRecord::Base

    # Tengo que decirle a User como usar la tabla project_assigned_users
    has_many :project_assigned_users

    # Para llegar a los projectos tengo que atravesar la tabla project_assigned_users
    has_many :projects, through: :project_assigned_users


end