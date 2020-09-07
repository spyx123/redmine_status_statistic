module RedmineStatusStatistic::QueriesHelperPatch
  extend ActiveSupport::Concern

  included do
    alias_method :column_content_without_status_statistic, :column_content
    alias_method :column_content, :column_content_with_status_statistic

    alias_method :query_to_csv_without_status_statistic, :query_to_csv
    alias_method :query_to_csv, :query_to_csv_with_status_statistic
  end
  
  def query_to_csv_with_status_statistic(items, query, options={})
    columns = query.columns
    logger.info columns
    if query.type=='IssueQuery' and not columns.index {|o| o.name == :status_statistic}.nil?
      Redmine::Export::CSV.generate(:encoding => params[:encoding]) do |csv|
        headers = columns.map {|c| c.caption.to_s}
        status_header_map = {}
        i = 0
        IssueStatus.all.each do |status|
          headers.append status.name
          status_header_map[status.id] = i
          i += 1
        end
        status_count = i + 1
        # csv header fields
        csv << headers
        # csv lines
        items.each do |item|
          status_data = Array.new status_count
          item.status_statistic.each do |s|
            status_data[status_header_map[s[:status].id]] = t(:value, scope: 'status_statistic', days: s[:days], hours: s[:hours])
          end
          csv << columns.map {|c| csv_content(c, item)} + status_data
        end
      end
    else
      query_to_csv_without_status_statistic(items, query, options)
    end
  end
  
  def column_content_with_status_statistic(column, item)
    if column.name == :status_statistic
      r = render :partial => "redmine_status_statistic/statistic", :locals => {:statistic => item.status_statistic}
    else
      r = column_content_without_status_statistic(column, item)
    end
    r
  end

end
