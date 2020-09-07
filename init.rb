plugin_name = :redmine_status_statistic

Redmine::Plugin.register plugin_name do
  name 'Redmine Status Statistic plugin'
  author 'Ivan Kolodeznikov'
  description 'Display time per each issue status.'
  version '0.0.1'
  url 'http://srv-dnp.argos.loc/gitlab/argosprogrammer/redmine_status_statistic'
end

require_dependency 'redmine_status_statistic/status_statistic_hook_listener'


Rails.configuration.to_prepare do
  include_patch_map =
    {
      ::RedmineStatusStatistic::IssuePatch => ::Issue,
      ::RedmineStatusStatistic::IssueQueryPatch => ::IssueQuery,
      ::RedmineStatusStatistic::QueriesHelperPatch => ::QueriesHelper,
    }
  include_patch_map.each_pair do |patch, target|
    target.send(:include, patch) unless target.included_modules.include?(patch)
  end
end
