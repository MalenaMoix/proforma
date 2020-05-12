class ProjectAssignedUserController < ApplicationController
    

    @projects_assigned_users = ProjectAssignedUser.all
    #@projects = ProjectAssignedUser.project
    #@users = ProjectAssignedUser.user
    

    def index
    end

end