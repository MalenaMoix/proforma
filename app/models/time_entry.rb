class TimeEntry < ActiveRecord::Base

    module TimeEntryPatch
        def self.included(base)
          base.class_eval do
            def assignable_users
                puts "ENTRA ACA"
                users = []
                if project
                  #users = project.members.active.preload(:user)
                  users = ProjectAssignedUser.where(:project_id => project.id).map(&:user)
                  users = users.map(&:user).select{ |u| u.allowed_to?(:log_time, project) }
                end
                users << User.current if User.current.logged? && !users.include?(User.current)
                users
            end
          end
        end
    end
      
    TimeEntry.send(:include, TimeEntryPatch) unless TimeEntry.included_modules.include?(TimeEntryPatch)

end