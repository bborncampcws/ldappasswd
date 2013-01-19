class User 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
 
  attr_accessor :name, :password
  
  def resetPassword
    false 
  end

  def initialize(attributes = {})
      @id=name
  end

  def persisted?
    false
  end

end
