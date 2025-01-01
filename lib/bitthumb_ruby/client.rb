module BitthumbRuby
  class Client
    attr_reader :public_api, :private_api

    # Initializes a new Client instance.
    #
    # If apikey and seckey are given, it also initializes a new PrivateApi
    # instance and assigns it to the instance variable.
    def initialize(apikey = nil, seckey = nil)
      @public_api = PublicApi.new
      @private_api = apikey && seckey ? PrivateApi.new(apikey, seckey) : nil
    end
  end
end
