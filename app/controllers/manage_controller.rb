class ManageController < ApplicationController
  def show
    return redirect_to(manage_events_path)
  end
end
