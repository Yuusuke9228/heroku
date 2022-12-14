class Member::BirthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    calendar = fetch_calendar(value[:era])
    if calendar.blank?
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:era]))
      return
    end

    year = value[:year]
    unless /\A[+-]?\d+\z/.match?(year)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:year]))
      return
    end

    month = value[:month]
    unless /\A[+-]?\d+\z/.match?(month)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:month]))
      return
    end

    day = value[:day]
    unless /\A[+-]?\d+\z/.match?(day)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:day]))
      return
    end

    year = year.to_i
    month = month.to_i
    day = day.to_i

    unless include_year_range?(calendar, year)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:year]))
      return
    end

    unless include_month_range?(calendar, year, month)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:month]))
      return
    end

    unless include_day_range?(calendar, year, month, day)
      record.errors.add(:in_birth, :invalid, **options.merge(value: value[:day]))
      return
    end
  end

  private

  def fetch_calendar(era)
    wareki = I18n.t("ss.wareki")[era.to_sym] rescue nil
    return nil if wareki.blank?
    min = Date.parse(wareki[:min])
    max = Date.parse(wareki[:max])

    [min, max]
  end

  def include_year_range?(setting, year)
    min, max = setting
    year >= 1 && (min.year + year - 1) <= max.year
  end

  def include_month_range?(setting, year, month)
    min, max = setting
    date = Date.new(min.year + year - 1, month, 1)
    month >= 1 && month <= 12 && date < max
  rescue
    false
  end

  def include_day_range?(setting, year, month, day)
    min, max = setting
    date = Date.new(min.year + year - 1, month, day)
    day >= 1 && day <= 31 && date < max
  rescue
    false
  end
end
