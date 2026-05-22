module ApplicationHelper
  def status_badge_class(status)
    case status.to_s
    when "active" then "badge badge-green"
    when "expired" then "badge badge-orange"
    when "suspended" then "badge badge-red"
    else "badge"
    end
  end
end
