class Ability
  include CanCan::Ability

  def initialize user, options = {}
    ######
    # NOTE:
    # The line below removes all authorization for all users.
    #
    # Remove the following line and uncomment the two subsequent lines
    # to enable authorization.
    ######
    can :manage, :all
    #@user = user || User.new
    #user ? user_rules : guest_user_rules
  end

  # Authorization rules for "guest" users.
  def guest_user_rules
    cannot :read, :all # guests are most un-welcome in our app!
  end

  # Authorization rules for "authenticated" users.
  def user_rules
    default_rules
    @user.roles.each do |role|
      meth = :"#{role}_rules"
      send(meth) if respond_to? meth
    end
  end

  ###############################################
  # The real Access Rules - one method per role.
  #

  # Super Admins can do anything they please!
  def super_admin_rules
    can :manage, :all
  end

  # Customers can only view attendance at their own sites.
  def customer_rules
    can :read, Attendance, {:customer_id => @user.customer_id}
  end

  # Staff can manage all master data and attendance.
  # They can only manage users with roles 'supervisor' and 'customer'.
  def staff_rules 
    can :manage, [Customer, Site, Attendance]
    can :manage, User, {:roles => {:id => Role.find_by_name('supervisor').id}}
    can :manage, User, {:roles => {:id => Role.find_by_name('customer').id}}
  end

  # All authenticated users can manage their own profiles.
  def default_rules
    can :update, :user, :id => @user.id
  end

end
