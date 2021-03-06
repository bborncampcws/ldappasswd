class UsersController < ApplicationController
  before_filter :authenticate_user!
  # GET /users
  def index
    @users=[]
    password=File.open('config/password','r').first.split("\n")[0]
    @errorr=''
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>password}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      treebase="ou=People,dc=cws,dc=net"
      attrs=["uid"]
      filter = Net::LDAP::Filter.eq( "uid", "*" )
      ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
         @users.push entry.uid[0]
      end
    @users.sort!
    else
        @errors=ldap.get_operation_result
    end
  end

  def destroy
    @user=User.new()
    @user.username=params[:id]
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  def edit
    user=params[:id]
    @user=User.new()
    @user.username=user
  end


  def show
    user=params[:id]
    @user=User.new()
    @user.username=user
  end


  def update
    user=params[:id]
    @user=User.new()
    @user.username=user
    if @user.update_password request.POST['user']['password']
      respond_to do |format|
        format.html {redirect_to :action => 'edit' , notice: "User #{@user.username} was updated."} 
      end
    else
      respond_to do |format|
        format.html {redirect_to :action => 'edit' , notice: 'User was NOT updated.'}
      end
    end
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.create
        format.html { redirect_to @user, notice: 'User was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end


end
