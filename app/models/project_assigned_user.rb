class ProjectAssignedUser < ActiveRecord::Base

    # EN ESTE CASO TENGO RELACION MUCHOS A MUCHOS ENTONCES
    # has_many :projects, class_name: "project", foreign_key: "project_id"
    # has_many :users, class_name: "user", foreign_key: "user_id"

    # Si no coloco belongs_to ActiveRecord me dejara crear un ProjectAssignedUser sin project_id ni user_id
    # Es decir, para que se cree un ProjectAssignedUser, se necesita si o si de un Project_id y un user_id
    # Tampoco reconocera .project() como un metodo
    belongs_to :project
    belongs_to :user

    
end