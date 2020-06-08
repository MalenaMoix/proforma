# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'proforma', :to => 'proforma#index'
post 'proforma/update_hours', :to => 'proforma#update_hours'
post 'proforma/block_proforma', :to => 'proforma#block_proforma'
post 'proforma/export_pdf', :to => 'proforma#export_pdf'


# OPTIMIZE
# Tal vez en vez de llamar al controller de proforma se pueda llamar al de project_assigned_user
post 'proforma', :to => 'proforma#new_project_assigned_user'
put 'proforma/update_project_assigned_user', :to => 'proforma#update_project_assigned_user'

#delete 'proforma/delete_project_assigned_user', :to => 'proforma#delete_project_assigned_user'