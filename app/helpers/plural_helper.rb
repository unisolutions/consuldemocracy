module PluralHelper
  def pluralize_balsai(count)
    last_two_digits = count % 100

    if count == 0 || last_two_digits % 10 == 0 || (11..19).include?(last_two_digits)
      return "#{count} balsų"
    elsif count % 10 == 1 && count % 100 != 11
      return "#{count} balsas"
    else
      return "#{count} balsai"
    end
  end
end
