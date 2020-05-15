# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'proforma', :to => 'proforma#index'
post 'proforma/update_hours', :to => 'proforma#update_hours'
post 'proforma/block_proforma', :to => 'proforma#block_proforma'
post 'proforma/export_pdf', :to => 'proforma#export_pdf'



# OPTIMIZE
post 'proforma', :to => 'proforma#new_project_assigned_user'
#post 'proforma/update_project_assigned_user', :to => 'proforma#update_project_assigned_user'