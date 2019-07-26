# frozen_string_literal: true

Dir['./routes/logcheck/*.rb'].each { |f| require f }

class LogCheck < Roda
  route('logcheck') do |r|
    store_current_functional_area('logcheck')

    r.multi_route('logcheck')
  end
end
