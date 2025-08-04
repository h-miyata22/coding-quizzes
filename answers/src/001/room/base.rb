module Room
  class Base
    def base_price
      raise NotImplementedError, 'This method should be overridden in subclasses'
    end

    def g_user_price_rate
      raise NotImplementedError, 'This method should be overridden in subclasses'
    end

    def aug_price_rate
      raise NotImplementedError, 'This method should be overridden in subclasses'
    end

    def name
      raise NotImplementedError, 'This method should be overridden in subclasses'
    end
  end
end
