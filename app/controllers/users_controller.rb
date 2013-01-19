class UsersController < ApplicationController
  # GET /users
  def index
    @users=[]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>"XXXXX"}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      treebase="ou=People,dc=cws,dc=net"
      attrs=["uid"]
      filter = Net::LDAP::Filter.eq( "uid", "*" )
      ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
         @users.push entry.uid
      end
    else
        @users=ldap.get_operation_result
    end

  end


  def edit
    user=params[:id]
    @user=User.new()
    @user.name=user
  end


  def show
    user=params[:id]
    @user=User.new()
    @user.name=user
  end


  def update
    user=params[:id]
    @user=User.new()
    @user.name=user

    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>"XXXXX"}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      dn = "uid=#{@user.name}, ou=people, dc=cws, dc=net"
      hash=Net::LDAP::Password.generate :md5, request.POST['user']['password']
     
    ldap.replace_attribute dn, :userPassword, hash
     
      respond_to do |format|
        format.html {redirect_to :action => 'edit' , notice: "User #{@user.name} was updated."} 
      end
    else
      respond_to do |format|
        format.html {redirect_to :action => 'edit' , notice: 'User was NOT updated.'}
      end
    end
  end

end
