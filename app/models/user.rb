class User <ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :rememberable, :trackable, :token_authenticatable
  #devise :ldap_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :remember_token
  attr_accessor :homedir

  #all this does is reset passwords
  def update_password(newPassword)
    password=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>password}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      dn = "uid=#{username}, ou=people, dc=cws, dc=net"
      hash=Net::LDAP::Password.generate :md5, newPassword 
      if ldap.replace_attribute dn, :userPassword, hash
        return true
      end
    end
    false
  end

  def admin?
    password=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>password}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if ldap.bind
      treebase="ou=Group,dc=cws,dc=net"
      attrs=["cn","gidNumber","memberuid"]
      filter = Net::LDAP::Filter.eq( "cn", "admin" )
      ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
         return !entry[:memberuid].index(username).nil?
      end
    else
        @errors=ldap.get_operation_result
    end
  end


  
  #destroy user from ldap
  def destroy
    ldapPassword=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>ldapPassword}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if (not username.empty?) and ldap.bind
      dn="uid=#{username},ou=People,dc=cws,dc=net"
      if ldap.delete :dn=>dn
        return true
      end
    end
      
    ldaperror=ldap.get_operation_result
    puts ldaperror
    errors.add "ldap could not add user #{ldaperror}",'ldap_errors'
    false
  end



  #create a new user in the ldap directory
#  def create
#    ldapPassword=File.open('config/password','r').first.split("\n")[0]
#    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>ldapPassword}
#    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
# 
#  #can we connect to the ldap server
#  if ldap.bind
#    treebase="ou=People,dc=cws,dc=net"
#    attrs=["uidNumber"]
#    filter = Net::LDAP::Filter.eq( "uid", "*" )
#    
#   #find next available uidNumber 
#    uidNumber='1'
#    ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
#       if entry[:uidnumber][0].to_i > uidNumber.to_i
#         uidNumber=entry[:uidnumber][0]
#       end
#    end
#
#    #prepare our data for entry to ldap
#    dn="uid=#{username},ou=People,dc=cws,dc=net"
#    attrs={  :uid=>username,
#      :cn=>username,
#      :objectClass=> ['account','posixAccount','top','shadowAccount'],
#      :shadowMax => '99999',
#      :shadowWarning => '7',
#      :loginShell => '/bin/bash',
#      :userPassword => password,
#      :uidNumber => uidNumber,
#      :gidNumber=> uidNumber,
#      :homeDirectory=>homedir }
#
#      #try to add new entry
#      if ldap.add(:dn=>dn,:attributes=>attrs)
#        true
#      else
#        ldaperror=ldap.get_operation_result
#        errors.add "ldap could not add user #{ldaperror}",'ldap.add errors'
#        errors.add attrs.to_s,'user_attributes'
#        false
#      end
#    else
#      ldaperror=ldap.get_operation_result
#      errors.add "ldap could not add user #{ldaperror}','ldap.add errors"
#      false
#    end
#  end
#
# 
#  def resetPassword
#    false 
#  end
#
#  def initialize(attributes = {})
#      @id=username
#      attributes.each do |attr, value|
#        self.public_send("#{attr}=", value)
#      end
#  end
#
#  def persisted?
#    false
#  end

end
