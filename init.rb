Redmine::Plugin.register :proforma do
  name 'Proforma plugin'
  author 'Folder IT'
  description 'Proforma stuff Nacho Juan FTW'
  version '0.1.0'
  settings :default => {:empty => true}, :partial => 'settings/proforma_settings'
  project_module :proforma do
    permission :view_planilla, :proforma => :index
    permission :change_planilla, :proforma => :update_hours
    permission :block_proforma, :proforma => :block_proforma
  end
  menu :project_menu, :proforma, {:controller => 'proforma', :action => 'index'}, :caption => 'Proforma', :after => :activity, :param => :project_id

end
