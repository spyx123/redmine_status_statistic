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

      last_time_assigned_to = self.created_on
      duration_map_assigned_to = {}
      duration_map_assigned_to.default = 0
      work_sec_assigned_to    = 0;
      
      self.journals.order(created_on: :asc).each do |record|
        detail = record.detail_for_attribute 'assigned_to_id'
        unless detail.nil?
          duration = last_time_assigned_to.business_time_until(record.created_on)
          last_time_assigned_to = record.created_on
          assigned_to_id = detail.old_value.to_i
          duration_map_assigned_to[assigned_to_id] = duration_map_assigned_to[assigned_to_id] + duration
        end
      end
      duration_map_assigned_to[self.assigned_to_id] = duration_map_assigned_to[self.assigned_to_id] + last_time_assigned_to.business_time_until(Time.zone.now)

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
      
      duration_map_assigned_to.keys.each do |assigned_to_id|
        assigned_to = User.find_by_id(assigned_to_id)
        if assigned_to.present?
          days, seconds = duration_map_assigned_to[assigned_to.id].divmod sec_per_business_day
          hours, o = seconds.divmod 3600
          result["assigned_to"].append({assigned_to: assigned_to, days: days, hours: hours, sec: duration_map_assigned_to[assigned_to.id]})
        end
      end  
      

      days, seconds = work_sec.divmod sec_per_business_day
      hours, o = seconds.divmod 3600
      result["total"] = {is_closed: IssueStatus.find(self.status_id).is_closed, days: days, hours: hours}

      result
    end

  end

end
