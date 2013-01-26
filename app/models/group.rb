class Group 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
 
  attr_accessor :groupname 
  
  #destroy group from ldap
  def destroy
    ldapPassword=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>ldapPassword}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if (not groupname.empty?) and ldap.bind
      dn="cn=#{groupname},ou=Group,dc=cws,dc=net"
      if ldap.delete :dn=>dn
        return true
      end
    end
      
    ldaperror=ldap.get_operation_result
    puts ldaperror
    errors.add "ldap could not add group #{ldaperror}",'ldap_errors'
    false
  end



  #create a new group in the ldap directory
  def create
    ldapPassword=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>ldapPassword}
    ldap=Net::LDAP.new(:host=>'ldap.cws.net',  :port=>636, :auth=>auth, :encryption=>:simple_tls)
 
  #can we connect to the ldap server
  if ldap.bind
    treebase="ou=Group,dc=cws,dc=net"
    attrs=["gidNumber"]
    filter = Net::LDAP::Filter.eq( "cn", "*" )
    
   #find next available gidNumber 
    gidNumber='1'
    ldap.search(:base=>treebase, :attributes=>attrs,:filter=>filter) do |entry|
       if entry[:gidnumber][0].to_i > gidNumber.to_i
         gidNumber=entry[:gidnumber][0]
       end
    end

    #prepare our data for entry to ldap
    dn="cn=#{groupname},ou=Group,dc=cws,dc=net"
    attrs={  :cn=>groupname,
      :objectClass=> ['posixGroup','top'],
      :gidNumber=> gidNumber  }

      #try to add new entry
      if ldap.add(:dn=>dn,:attributes=>attrs)
        true
      else
        ldaperror=ldap.get_operation_result
        errors.add "ldap could not add group #{ldaperror}",'ldap.add errors'
        errors.add attrs.to_s,'group_attributes'
        false
      end
    else
      ldaperror=ldap.get_operation_result
      errors.add "ldap could not add group #{ldaperror}','ldap.add errors"
      false
    end
  end


  def initialize(attributes = {})
      @id=groupname
      attributes.each do |attr, value|
        self.public_send("#{attr}=", value)
      end
  end

  def persisted?
    false
  end

end
