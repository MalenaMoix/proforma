class ProjectAssignedUser < ActiveRecord::Base

    # Si no coloco belongs_to ActiveRecord me dejara crear un ProjectAssignedUser sin project_id ni user_id
    # Es decir, para que se cree un ProjectAssignedUser, se necesita si o si de un Project_id y un user_id
    # Tampoco reconocera .project() como un metodo
    belongs_to :project
    belongs_to :user

end