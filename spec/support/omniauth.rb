# Public: Mock OmniAuth to respond with an auth hash when /auth/instagram is
# visited.
#
# uid - UID you want it to respond with. Use this to simulate logging in as a
# user already in the database. Leave as nil to get a random response (e.g.
# a new user).
def mock_omniauth(uid=nil, name="John Doe", nickname="johndoe")
  OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
    provider: "twitter",
    uid: uid || SecureRandom.hex,
    credentials: {token: "auth-token"},
    info: {image: "http://example.com/profile.jpg", name: name, nickname: nickname}
  })
end
