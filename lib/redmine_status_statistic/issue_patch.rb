module RedmineStatusStatistic::IssuePatch
  extend ActiveSupport::Concern

  included do

    def status_statistic

      last_time = self.created_on
      duration_map = {}
      duration_map.default = 0
      work_sec    = 0;
      
      self.journals.order(created_on: :asc).each do |record|
        detail = record.detail_for_attribute 'status_id'
        unless detail.nil?
          duration = last_time.business_time_until(record.created_on)
          last_time = record.created_on
          status_id = detail.old_value.to_i
          duration_map[status_id] = duration_map[status_id] + duration
        end
      end
      duration_map[self.status_id] = duration_map[self.status_id] + last_time.business_time_until(Time.zone.now)

      result = {"statuses"=>[], "assigned_to"=>[], "total"=>[]}

      sec_per_business_day = BusinessTime::Config.end_of_workday - BusinessTime::Config.beginning_of_workday


      duration_map.keys.each do |status_id|
        status = IssueStatus.find_by_id(status_id)

        if status.present?
          days, seconds = duration_map[status.id].divmod sec_per_business_day
          hours, o = seconds.divmod 3600
          result["statuses"].append({status: status, days: days, hours: hours})

          if !status.is_closed?
           work_sec += duration_map[status.id]
          end
        end
      end
      
      days, seconds = work_sec.divmod sec_per_business_day
      hours, o = seconds.divmod 3600
      result["total"] = {is_closed: IssueStatus.find(self.status_id).is_closed, days: days, hours: hours}

      result
    end

  end

end
