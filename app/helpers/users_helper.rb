module UsersHelper
  def fullname_and_affiliation(user)
    return [h(user.fullname), h(user.affiliation)].reject(&:blank?).join(' - ')
  end
end
