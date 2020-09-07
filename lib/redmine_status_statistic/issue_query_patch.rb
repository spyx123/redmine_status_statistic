module RedmineStatusStatistic::IssueQueryPatch
  extend ActiveSupport::Concern

  included do
    self.available_columns.append(QueryColumn.new(:status_statistic, :inline => false))
  end
  
end
