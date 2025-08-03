module Room
  class Single < Base
    def base_price
      8000
    end

    def g_user_price_rate
      0.9
    end

    def aug_price_rate
      1.5
    end

    def name
      'Single Room'
    end
  end
end
