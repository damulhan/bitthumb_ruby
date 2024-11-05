module BitthumbRuby
  class Client
    attr_reader :public_api, :private_api

    # Initializes a new Client instance.
    #
    # If conkey and seckey are given, it also initializes a new PrivateApi
    # instance and assigns it to the instance variable.
    def initialize(conkey = nil, seckey = nil)
      @public_api = PublicApi.new
      @private_api = conkey && seckey ? PrivateApi.new(conkey, seckey) : nil
    end
  end
end
