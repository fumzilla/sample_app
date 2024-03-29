module ApplicationHelper

  # Return the logo image
  def logo
    image_tag("logo.png", :alt => "Sample Application", :class => "round")
  end
  
  # Return a title based on the page.
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
        base_title
    else
        "#{base_title} | #{@title}"
    end
  end   

end
