module UserFavoritesHelper
  # Add JavaScript to layout that populates the user's favorites and binds these controls.
  def include_user_favorites_javascript
    expose_to_js :favorites_path, user_favorites_path(:user_id => :me)
    run_when_dom_is_ready 'populate_user_favorites();'
    run_when_dom_is_ready 'bind_user_favorite_controls();'
  end

  # Return link for a UserFavorite control for the given +proposal+.
  def user_favorite_control_for(proposal)
    return link_to(content_tag(:span, "*"), user_favorites_path(:me), :class => "favorite favorite_#{proposal.id}")
  end
end
