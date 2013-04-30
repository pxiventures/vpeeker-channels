# Internal: Subdomain matcher class for routes.
class Subdomain
  def self.matches?(request)
    case request.subdomains[0]
    when 'www', '', nil, 'channels', Rails.env
      false
    else
      true
    end
  end
end
