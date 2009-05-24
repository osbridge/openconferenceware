module UserFavoritesHelper
  def include_user_favorites_javascript
    expose_to_js :favorites_path, user_favorites_path(:user_id => :me)
    run_when_dom_is_ready 'populate_user_favorites();'
    run_when_dom_is_ready 'bind_user_favorite_controls();'
  end
end
