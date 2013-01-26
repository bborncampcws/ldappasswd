class GroupsController < ApplicationController
  # GET /groups
  def index
    @groups=[]
    password=File.open('config/password','r').first.split("\n")[0]
    @errorr=''
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>password}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      treebase="ou=Group,dc=cws,dc=net"
      attrs=["cn"]
      filter = Net::LDAP::Filter.eq( "cn", "*" )
      ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
         @groups.push entry.cn[0]
      end
    @groups.sort!
    else
        @errors=ldap.get_operation_result
    end
  end

  def destroy
    @group=Group.new()
    @group.groupname=params[:id]
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
    end
  end

  def edit
    group=params[:id]
    @group=Group.new()
    @group.groupname=group
  end


  def show
    group=params[:id]
    @group=Group.new()
    @group.groupname=group
  end


  def update
  end

  def create
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.create
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def new
    @group = Group.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end


end
