class ProformaController < ApplicationController
  unloadable

  # noinspection RubyResolve
  before_action :find_project, :authorize, :only => [:index, :block_proforma, :update_hours]


  def index
    current = User.current
    if current.admin || has_role?(current, 'Jefe de proyecto')
      get_manager_index
    else
      get_dev_index(current)
    end
  end


  def get_dev_index(current)
    if has_role?(current, 'Desarrollador')
      month_to_show = DateTime.new(DateTime.now.year, DateTime.now.month, 1)
      @proformas = [current]
      @time_entries = TimeEntry.where(:user_id => current.id, :tmonth => month_to_show.month, :tyear => month_to_show.year, :project_id => @project[:id])
    end
  end

  def get_manager_index
    @months = TimeEntry.select('tyear, tmonth').where(:project_id => @project[:id]).group('tyear, tmonth')
    month_to_show = params[:month] ? DateTime.parse(params[:month]) : DateTime.new(DateTime.now.year, DateTime.now.month, 1)
    all = @project.members.all
    ids = []
    ids_aux = []

    all.each do |a|
      ids_aux.push a[:user_id]
    end

    settings = Setting.plugin_proforma['block_'+params[:project_id]+'']
    if settings
      block_date = DateTime.strptime(settings, '%Y-%m-%d')
    else
      block_date = DateTime.new(2014, 1, 1)
    end

    ids_aux.each do |id|
      user = User.where(id: id)
      current_month = month_to_show.year == DateTime.now.year && month_to_show.month == DateTime.now.month

      hasHours = hasHours?(id, month_to_show)
      hasRole = has_role?(user[0], 'Activo')

      if hasHours || (current_month && hasRole)
        ids.push id
      end
    end
    @proformas = User.where(id: ids)
    @time_entries = TimeEntry.where(user_id: ids, :tmonth => month_to_show.month, :tyear => month_to_show.year, :project_id => @project[:id])
  end

  def get_admin_index
    @months = TimeEntry.select('tyear, tmonth').where(:project_id => @project[:id]).group('tyear, tmonth')
    month_to_show = params[:month] ? DateTime.parse(params[:month]) : DateTime.now
    @proformas = User.all
    @time_entries = TimeEntry.where(:tmonth => month_to_show.month, :tyear => month_to_show.year, :project_id => @project[:id])
  end

  def has_role?(current, role)
    current.roles_for_project(@project).include?(Role.find_by(:name => role))
  end

  def hasHours?(id, month_to_show)
    time_entry= TimeEntry.where("user_id = ? and tmonth = ? and tyear = ? and project_id = ? and (hours > 0 or (comments is not null and comments != '') )",
                                id, month_to_show.month, month_to_show.year, @project[:id])
    time_entry[0] ? true : false
  end


  def round_to_quarter (val)
    (val.to_f * 4).round / 4.0
  end


  def new
    @proforma = Proforma.new
  end

  def update_hours
    hours = []
    if User.current.admin || has_role?(User.current, 'Jefe de proyecto')
      month_to_update = params[:month] != '' ? DateTime.parse(params[:month]) : DateTime.now
    else
      if params[:month] != ''
        month_to_update = DateTime.now
      else
        month_to_update = DateTime.now
      end
    end
    # noinspection RubyResolve
    settings = Setting.plugin_proforma['block_'+params[:project_id]+'']
    if settings
      block_date = DateTime.strptime(settings, '%Y-%m-%d')
    else
      block_date = DateTime.new(2014, 1, 1)
    end


    params['day'].each do |i|
      # i[0] -> user
      # i[1] -> j
      i[1].each do |j|
        # j[0] -> day
        # j[1][:hours] -> hours spent
        # j[1][:comment] -> comment
        # j[1][:activityId] -> activity_id
        if j[1][:hours] && round_to_quarter(j[1][:hours]) >= 0 && round_to_quarter(j[1][:hours]) <= 24
          comment = j[1][:comment]
          strip = comment ? comment.strip! : ''

          activity = if (User.current.admin || has_role?(User.current, 'Jefe de proyecto')) && j[1][:activityId]
                       j[1][:activityId].length > 0 ? j[1][:activityId] : nil
                     else
                       nil
                     end
          hours.push({:time => round_to_quarter(j[1][:hours]),
                      # strip! returns nil if there is no text to trim...
                      :comments => strip ? strip : comment,
                      :day => j[0].to_i, :user => i[0], :activity_id => activity})
        end
      end
    end

    pr_id = params[:project_id]
    resultUpdate = []
    resultInsert = []
    success_array = hours.map {|hour|
      date_time_new = DateTime.new(month_to_update.year, month_to_update.month, hour[:day])
      if date_time_new > block_date
        if (time_entry_old = record_exists?(date_time_new, hour[:user], pr_id))
          r = false
          if hour[:activity_id]
            r = time_entry_old.update(:hours => hour[:time], :comments => hour[:comments], :activity_id => hour[:activity_id])
          else
            # Hardcoded until customization
            if User.current.admin || has_role?(User.current, 'Jefe de proyecto')
              r = time_entry_old.update(:hours => hour[:time], :comments => hour[:comments], :activity_id => TimeEntryActivity.where(name: 'Desarrollo')[0].id)
            else
              r = time_entry_old.update(:hours => hour[:time], :comments => hour[:comments])
            end
          end
          resultUpdate.push(hour[:user].to_s + ", " + hour[:day].to_s => [r, hour[:activity_id], hour[:time]].join(","))
          r
        else
          time_entry_new = TimeEntry.new(
              :comments => hour[:comments],
              :spent_on => date_time_new,
              :activity_id => hour[:activity_id] ? hour[:activity_id] : TimeEntryActivity.where(name: 'Desarrollo')[0].id)
          time_entry_new.hours = hour[:time]
          time_entry_new.user_id = hour[:user]
          time_entry_new.project_id = pr_id
          r = time_entry_new.save
          resultInsert.push(hour[:user].to_s + ", " + hour[:day].to_s => [r, hour[:activity_id], hour[:time]].join(","))
          r
        end
      else
        true
      end
    }

    blocked_feedback = block_date >= DateTime.new(month_to_update.year, month_to_update.month, -1)
    @issue = Issue.new
    if !params[:proforma_seguimiento].blank? && !blocked_feedback && (User.current.admin || has_role?(User.current, 'Jefe de proyecto'))
      issue_month_to_update = DateTime.new(month_to_update.year, month_to_update.month, 1)
      @issue = Issue.where(:tracker_id => Tracker.where(:name => "Seguimiento")[0].id,
                           :project_id => pr_id,
                           :start_date => issue_month_to_update)

      if @issue && @issue[0]
        @issue = @issue[0]
        @issue.subject = "Seguimiento " + issue_month_to_update.strftime('%Y-%m-%d')
        @issue.description = params[:proforma_seguimiento]
        @issue.start_date = issue_month_to_update
      else
        #success_array.push(update_seguimiento(params))
        @issue = Issue.new
        @issue.project_id = pr_id
        @issue.subject = "Seguimiento " + issue_month_to_update.strftime('%Y-%m-%d')
        @issue.description = params[:proforma_seguimiento]
        @issue.start_date = issue_month_to_update
        @issue.tracker_id = Tracker.where(:name => "Seguimiento")[0].id
        @issue.due_date = issue_month_to_update
        @issue.assigned_to_id = User.current.id
        @issue.author_id = User.current.id
        @issue.start_date = issue_month_to_update
      end
      iss = @issue.save
    end

    if success_array.all?
      flash[:notice] = 'Proforma guardada'
    else
      flash[:alert] = 'Un error ha ocurrido. Por favor revise la proforma e intente nuevamente.'
    end

    # noinspection RailsParamDefResolve
    date_to_redirect = month_to_update.year.to_s+"-"+month_to_update.month.to_s+"-1"
    if params[:month]
      redirect_to :action => 'index', :project_id => params[:project_id], :month => date_to_redirect
    else
      redirect_to :action => 'index', :project_id => params[:project_id]
    end
  end

  def record_exists?(date_time_new, user, project_id)
    TimeEntry.find_by(:spent_on => date_time_new, :user_id => user, :project_id => project_id)
  end

  def block_proforma
    find_project
    string = 'block_'+ params[:project_id]+''
    if /\d{4}-\d{2}-\d{2}/.match(params[string])
      old_settings = Setting.send 'plugin_proforma'
      # safe?
      old_settings[string] = params[string]
      Setting.send 'plugin_proforma=', old_settings
    end
    # noinspection RailsParamDefResolve
    redirect_to :action => 'index', :project_id => params[:project_id]
  end


  # Can be improved! Repeated code and unnecessary repetition .each
  # noinspection RubyNestedTernaryOperatorsInspection
  def export_pdf
    month_to_show = params[:month] ? DateTime.parse(params[:month]) : DateTime.now
    project = Project.find(params[:project_id])
    all = project.members.all
    ids = []
    all.each do |a|
      ids.push a[:user_id]
    end
    @proformas = User.where(id: ids)
    @time_entries = TimeEntry.where(user_id: ids, :tmonth => month_to_show.month, :tyear => month_to_show.year, :project_id => params[:project_id])
    this_month_days = params[:days].to_i
    arr_day_names = %w(L M M J V S D)
    first_day_name = params[:first_day].to_i
    @pdf = RBPDF.new('L')
    @pdf.set_creator(User.current)
    @pdf.set_author(User.current)
    # @pdf.set_header_data("#{File.join(Rails.root.to_s, 'public')}/images/folder-it-logo-header-blog.png", 20,
    #                      'folder_image', "first row\nsecond row\nthird row")
    @pdf.set_margins(15, 27, 15)
    @pdf.set_auto_page_break(true, 25)
    @pdf.set_font('', 'B', 7)
    # @pdf.set_image_scale(4); #set image scale factor
    @pdf.alias_nb_pages
    @pdf.add_page

    @pdf.write_html("<h1>Proforma #{project}</h1>
     <p>R-P3.1/1 Vigencia: 29-Oct-2013 PROFORMA STAFF AUGMENTATION</p>
     -----imagen----<br/>
     <p>Mes:#{TimeEntry.month_name(month_to_show.month) + '/' + month_to_show.year.to_s}</p>",
                    true, 1)

    @pdf.image('/opt/bitnami/apps/redmine/htdocs/public/plugin_assets/proforma/images/folder-it-logo-header-blog.png')
    # @pdf.image('/opt/bitnami/apps/redmine/htdocs/plugins/proforma/assets/images/folder-it-logo-header-blog.png')

    @pdf.set_fill_color(120, 61, 100)
    first_column_width = 35
    first_column_margin = 14
    row_y = 65
    row_height = 5

    # LMMJVSD row
    @pdf.write_html_cell(first_column_width, 0, first_column_margin, row_y, '', 'TLB', 0, 1, true, 'C')
    first_column_total = 49
    (0..(this_month_days - 1)).to_a.each do |d|
      @pdf.write_html_cell(7, 0, first_column_total+(d*7), row_y, "
       <p style='background-color:#783d64;color:white'>#{arr_day_names[((first_day_name - 1) + d) % 7]}</p>
       ", 'TB', 0, 1, true, 'C')
    end
    last_column_width = 28
    all_days_width = this_month_days*7
    @pdf.write_html_cell(last_column_width, 0, all_days_width+first_column_total, row_y, '', 'TRB', 1, 1, true, 'C')

    # Next row
    row_y+=row_height


    # Second header row (title - 1..31 - titles)
    @pdf.write_html_cell(first_column_width, 0, first_column_margin, row_y, '<p style="color:white">Recurso</p>', 'TLB', 0, 1, true, 'C')
    (0..(this_month_days - 1)).to_a.each do |d|
      @pdf.write_html_cell(7, 0, first_column_total+(d*7), row_y, "
       <p style='background-color:#783d64;color:white'>#{d+1}</p>
       ", 'TB', 0, 1, true, 'C')
    end
    last_column_width = 28
    @pdf.write_html_cell(last_column_width/2, 0, all_days_width+first_column_total, row_y,
                         '<p style="color:white">Total</p>', 'TB', 1, 1, true, 'C')
    @pdf.write_html_cell(last_column_width/2, 0, all_days_width+first_column_total+last_column_width/2, row_y,
                         '<p style="color:white">Hábiles</p>', 'TRB', 1, 1, true, 'C')

    # Next row
    row_y+=row_height

    # User/hours row
    @project = project
    time_entry_activity = TimeEntryActivity.where(name: 'Timeoff')[0]
    var0 = Setting.plugin_proforma['feriados']
    holidays = var0 ? var0.split(',') : []
    @pdf.set_fill_color(128, 128, 128)
    comments = []

    @proformas.each do |p|
      total=0
      workable=0
      @pdf.write_html_cell(first_column_width, 0, first_column_margin, row_y, "<p>#{p}</p>", 1, 0, 0)
      (0..(this_month_days-1)).to_a.each do |d|
        date_time_new = DateTime.new(month_to_show.year, month_to_show.month, d+1)
        var1 = @time_entries.where(:spent_on => date_time_new, :user_id => p[:id])[0]
        is_activity_timeoff = var1[:activity_id] == time_entry_activity[:id]
        background_color = (date_time_new.saturday? || date_time_new.sunday? || holidays.include?(date_time_new.strftime('%m/%d/%Y'))) ? 1 : (is_activity_timeoff ? 1 : 0)
        day_hours = var1 ? (var1[:hours].round != 0 ? var1[:hours].round : nil) : nil
        @pdf.write_html_cell(7, 0, first_column_total+(d*7), row_y, "
           <p>#{day_hours}</p>
           ", 1, 0, background_color, true, 'C')
        total += day_hours ? day_hours : 0
        workable += background_color == 0 ? 8 : 0
        if var1 && var1[:comments].strip != ''
          comments.push(:time_entry => var1, :username => p)
        end

      end
      @pdf.write_html_cell(last_column_width/2, 0, all_days_width+first_column_total, row_y, total.to_s, 1, 1, 0, true, 'C')
      @pdf.write_html_cell(last_column_width/2, 0, all_days_width+first_column_total+last_column_width/2, row_y, workable.to_s, 1, 1, 0, true, 'C')
      # Next row
      row_y+=row_height
    end

    @pdf.set_fill_color(120, 61, 100)
    # Adds blank space
    row_y+= row_height*3
    @pdf.write_html_cell(first_column_width, 0, first_column_margin, row_y, '<p style="color:white">Persona</p>', 1, 0, 1, true, 'C')
    @pdf.write_html_cell(21, 0, first_column_total, row_y, '<p style="color:white">Día</p>', 1, 0, 1, true, 'C')
    @pdf.write_html_cell(all_days_width+7, 0, first_column_total + 21, row_y, '<p style="color:white">Comentarios</p>', 1, 0, 1, true, 'C')

    # Next row
    row_y+=row_height
    # Shouldn't iterate again, todo merge with previous .each (setting the x,y will be needed)
    comments.each do |c|
      @pdf.write_html_cell(first_column_width, 0, first_column_margin, row_y, c[:username].name, 1, 1, 0, true, 'C')
      @pdf.write_html_cell(21, 0, first_column_total, row_y, c[:time_entry][:spent_on].day.to_s, 1, 1, 0, true, 'C')
      @pdf.write_html_cell(all_days_width+7, 0, first_column_total + 21, row_y, c[:time_entry][:comments], 1, 1, 0, true, 'C')
      # Next row
      row_y+=row_height
    end

    # I really need to figure out how to do this, "racing conditions a lo loco", still testing
    file = @pdf.output
    @attachment = Attachment.new(:file => file)
    @attachment.author = User.current
    @attachment.filename = Redmine::Utils.random_hex(16).to_s + '.pdf'
    @attachment.container_id = params[:project_id]
    @attachment.container_type = 'Project'
    @attachment.save


    # noinspection RailsParamDefResolve
    redirect_to :action => 'index', :project_id => params[:project_id]

  end


  private

  def find_project
    @project = Project.find(params[:project_id])
  end


end
