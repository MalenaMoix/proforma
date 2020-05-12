class ProjectAssignedUserController < ApplicationController
    

    @projects_assigned_users = ProjectAssignedUser.all
    #@projects = ProjectAssignedUser.projects
    #@users = ProjectAssignedUser.users
    

    def index
    end

end