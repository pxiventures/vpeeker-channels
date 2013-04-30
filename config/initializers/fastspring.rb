$fastspring = FastSpring.new(AppConfig.fastspring.store_id,
                             AppConfig.fastspring.username,
                             AppConfig.fastspring.password)

$fastspring.test_mode = (Rails.env =~ /development/i) ? true : false
