module Room
  class Suite < Base
    def base_price
      20000
    end

    def g_user_price_rate
      0.9
    end

    def aug_price_rate
      1.5
    end

    def name
      'Suite'
    end
  end
end
