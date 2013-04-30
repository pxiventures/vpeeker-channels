FactoryGirl.define do
  factory :video do
    channel
    video_url "http://vine.co/example"
    vine_url "http://vine.co/example.mp4"
    thumbnail_url "http://vine.co/thumbnail.jpg"
  end
end
