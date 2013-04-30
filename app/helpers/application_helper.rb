module ApplicationHelper

  # Public: Returns a link that is disabled if the restriction check fails.
  #
  # text - Text of the link
  # url - URL for link
  # permitted - Whether the link should be permitted or disabled (true / false)
  # options - options to pass to link_to
  def restricted_link_to(text, url, permitted, options={})
    link_class = (options[:class] || "") + (permitted ? "" : " disabled")
    options[:class] = link_class
    extra = !permitted ? content_tag(:span, "Upgrade", class: "label label-important") : nil
    link_to url, options do
      content_tag(:span, text + " ") + extra
    end
  end

  # Public: Returns an <li> that has a class of 'active' if the route you
  # supplied is the page the user is currently on.
  #
  # Example:
  #
  #   nav_link("Home", root_path)
  #   # => '<li class="active"><a href="/">Home</a></li>'
  #   # (If the helper is called on the home page)
  def nav_link(text, route)
    content_tag(:li, class: current_page?(route) ? "active" : "") do
      link_to text, route
    end
  end

  # Public: Returns a set of <td> elements for all the plans, calling l to get
  # the data.
  def pricing_cells(plans, l)
    plans.map{|plan|
      content = l.call(plan)
      content_tag(:td, content, class: [(current_user and current_user.plan == plan ? "active" : ""), (content == "Y" ? "green" : "")].join(" "))
    }.join.html_safe
  end

end
