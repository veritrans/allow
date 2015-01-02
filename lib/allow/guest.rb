class Allow::Guest
  include Allow::Model

  def roles
    [:guest]
  end
end
