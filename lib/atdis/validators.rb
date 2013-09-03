require 'active_model'

class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    if raw_value.present? && !value.kind_of?(DateTime)
      record.errors.add(attribute, "is not a valid date")
    end
  end
end

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    if raw_value.present? && !value.kind_of?(URI)
      record.errors.add(attribute, "is not a valid URL")
    end
  end
end

# Take into account the value before type casting
class PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    unless raw_value.present?
      record.errors.add(attribute, "can't be blank")
    end
  end
end
