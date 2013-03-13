class Ldap
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :connection, :host, :port, :login, :password
 
  def initialize(attributes = {})
    attributes.each do |attr, value|
      self.public_send("#{attr}=", value)
    end
    self.password=File.open('config/password','r').first.split("\n")[0]
    auth = {:method=>:simple, :username=>"cn=admin,dc=cws,dc=net", :password=>self.password}
    self.connection=Net::LDAP.new(:host=>'ldap.cws.net', :port=>636, :auth=>auth, :encryption=>:simple_tls)
    if self.connection.bind
     return true
    else
     return false
  end

  def persisted?
    false
  end

end

