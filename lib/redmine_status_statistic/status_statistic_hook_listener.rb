class StatusStatisticHookListener < Redmine::Hook::ViewListener

  def view_issues_show_description_bottom(context = {})
    context[:hook_caller].send(:render, {
      :partial => "redmine_status_statistic/issue_view_statistic",
      :locals => {:statistic => context[:issue].status_statistic }
    })
  end
end
