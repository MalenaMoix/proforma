class FacturationController < ApplicationController

    def index
        #@project = Project.find(params[:project_id])
        @facturations = Facturation.all
    end
end