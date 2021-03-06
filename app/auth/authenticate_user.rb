# app/auth/authenticate_user.rb
class AuthenticateUser
  def initialize(email, password)
    @email = email
    @password = password
  end

  # Service entry point
  def call
    if user
      response = { auth_token: JsonWebToken.encode(user_id: user.id), is_doctor: !user.doctor.nil?, fullname: user[:fullname], date_of_birth: user[:date_of_birth] }
      response[:doctor_id] = 0
      response[:doctor_id] = user.doctor.id unless user.doctor.nil?
      return response
    end
  end

  private

  attr_reader :email, :password

  # verify user credentials
  def user
    user = User.find_by(email: email)
    return user if user && user.authenticate(password)
    # raise Authentication error if credentials are invalid
    raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
  end
end
