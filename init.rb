Redmine::Plugin.register :proformanext do
  name 'Proforma 2.0 plugin'
  author 'Folder IT'
  description 'Proforma stuff Nacho Juan FTW'
  version '0.2.0'
  settings :default => {:empty => true}, :partial => 'settings/proformanext_settings'
  
  project_module :proformanext do
    permission :view_planillaa, :proformanext => :index
    permission :change_planillaa, :proformanext => :update_hours
    permission :block_proformanext, :proformanext => :block_proformanext
    permission :administrativo_facturacion, :proformanext => :administrativo_facturacion
  end

  menu :project_menu, :proformanext, {:controller => 'proformanext', :action => 'index'}, :caption => 'Proformanext', :after => :activity, :param => :project_id
end