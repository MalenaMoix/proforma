class ProjectAssignedUserController < ApplicationController
    
    @projects_assigned_users = ProjectAssignedUser.all

    def index
    end

    def new_project_assigned_user
        @employee2 = ProjectAssignedUser.new
        @employee2.save
    end

    def update
    end

    def create
    end

end