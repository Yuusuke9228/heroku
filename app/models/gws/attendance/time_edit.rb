class Gws::Attendance::TimeEdit
  extend SS::Translation
  include ActiveModel::Model
  include SS::PermitParams

  attr_accessor :cur_site, :cur_user, :in_hour, :in_minute, :in_reason

  permit_params :in_hour, :in_minute, :in_reason

  # validates :in_hour, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 24, allow_blank: true }
  validates :in_hour, numericality: { only_integer: true, allow_blank: true }
  validate :validates_in_hour
  validates :in_minute, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60, allow_blank: true }
  validates :in_reason, presence: true, length: { maximum: 80 }

  class << self
    def t(*args)
      human_attribute_name(*args)
    end
  end

  def calc_time(date)
    if in_hour.blank? || in_minute.blank?
      return nil
    else
      date.beginning_of_day + Integer(in_hour).hours + Integer(in_minute).minutes
    end
  end

  private

  def validates_in_hour
    return if errors.present?
    return if in_hour.blank?

    start_hour = @cur_site.attendance_time_changed_minute / 60
    if Integer(in_hour) < start_hour
      errors.add :in_hour, :greater_than_or_equal_to, count: start_hour
    end
    if Integer(in_hour) > start_hour + 24
      errors.add :in_hour, :less_than_or_equal_to, count: start_hour + 24
    end
  end
end
