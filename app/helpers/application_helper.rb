# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include SearchHelper
  include ActionView::Helpers::JavaScriptHelper
  
  #! ------ stopgap helpers ------
  
  def visual_effect(*args)  #! stopgap for 3.2 port
    puts '---------------------> visual_effect needs to be replaced for 3.2'
    ''
  end
  
  def observe_form(*args)  #! stopgap for 3.2 port
    puts '---------------------> observe_form needs to be replaced for 3.2'
    ''
  end
  
  def link_to_ajax(text, opts)
    opts.reverse_merge! method: :post, remote: true, 'data-type' => 'html'
    path = opts.delete(:url)
    opts['data-update'] = opts.delete(:update)
    link_to text, path, opts
  end
  
  def form_for_ajax(record, opts = {}, &block)
    opts.reverse_merge! remote: true, 'data-type' => 'html', html: {}
    opts[:html]['data-update'] = opts.delete(:update)
    form_for(record, opts, &block)
  end

  def form_tag_ajax(opts, &block)
    opts.reverse_merge! remote: true, 'data-type' => 'html', html: {}
    opts[:html]['data-update'] = opts.delete(:update)
    form_tag(opts, &block)
  end
  
  
  def logged_in?
    !current_user.nil?
  end
  
  def user_formatted_text(text)
    # Handles free-form text for ideas and comments.
    # We could drop in some more elaborate formatting rules here if we want to,
    # but be careful about XSS attacks!
    Rinku.auto_link h(text).strip.gsub(/(\n|\r\n|\r)/, '<br/>'), :urls, 'rel="nofollow"'
  end
  
  def idea_owner?(idea)
    logged_in? && current_user.id == idea.inventor_id
  end
  
  def has_voted?(idea)
    # Cache all ideas voted on by this user to avoid doing O(n) queries
    @voted_for_idea_ids ||= if current_user
       Vote.find(:all, :conditions => {:user_id=>current_user.id}, :select=>'votes.idea_id').map{|x| x.idea_id}
    else
      []
    end
    
    logged_in? && (idea_owner?(idea) || @voted_for_idea_ids.include?(idea.id))
  end
  
  def flagged_as_inappropriate?(model)
    session[flagged_as_inappropriate_session_key(model)]
  end
  
  def flagged_as_inappropriate(model)
    session[flagged_as_inappropriate_session_key(model)] = true
  end
  
  def ideax_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    in_place_editor_options.reverse_merge!(
      :save_text => 'Save',
      :cancel_text => 'Cancel',
      :options => '{}, highlightcolor: "#FFFFFF"')  # This is a nasty hack to disable the highlight, but it works
    in_place_editor_field(object, method, tag_options, in_place_editor_options)
  end
  
  # Path to full-page map for given ideas
  def map_ideas_path(ideas)
    map_path(:idea_ids => ideas.map{ |idea| idea.id }.join(' '))
  end
  
  # IE doesn't fire onchange for checkboxes until blur. This helper method repeats a JS action
  # for change, click, and keypress actions so that checkboxes respond immediately in any browser.
  def check_box_onchange(action, opts = {:onchange => true})
    if opts[:onchange]
      { :onclick => action, :onkeypress => action, :onchange => action }
    else
      { :onclick => action, :onkeypress => action }
    end
  end
  
  def rss_date(time)
    time.strftime '%a, %d %b %Y %H:%M:%S %z'
  end
  
  def xml_pagination_attrs(p)
    { 'first-index' => (p.current_page-1) * p.per_page,
      'page-size' => p.per_page,
      'count' => p.size,
      'total-count' => p.total_entries }
  end
  
  def avatar_for(user, opts = {})
    opts[:default] ||= "/images/default-avatar-#{opts[:size] || 50}.png"
    unless opts[:default] =~ /:\/\//
      opts[:default] = request.protocol + request.host_with_port + opts[:default]
    end
    
    "<img src='#{h opts[:default]}' width='#{h opts[:size]}' height='#{h opts[:size]}'>".html_safe
    #! use gravatar
  end
  
private
  
  def flagged_as_inappropriate_session_key(model)
    "xxx:#{model.class}:#{model.id}"
  end
  
  DEFAULT_MAP_CENTER = [39.232253, -96.503906]
  DEFAULT_MAP_ZOOM = 4
  DEFAULT_MINIMAP_ZOOM = 2
  
end
