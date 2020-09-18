# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'proformanext', :to => 'proformanext#index'
post 'proformanext/update_hours', :to => 'proformanext#update_hours'
post 'proformanext/block_proformanext', :to => 'proformanext#block_proformanext'
post 'proformanext/export_pdf', :to => 'proformanext#export_pdf'


# OPTIMIZE
# Tal vez en vez de llamar al controller de proformanext se pueda llamar al de project_assigned_user
post 'proformanext', :to => 'proformanext#new_project_assigned_user'
put 'proformanext/update_project_assigned_user', :to => 'proformanext#update_project_assigned_user'

delete 'proformanext/delete_project_assigned_user', :to => 'proformanext#delete_project_assigned_user'