module MWS
  module API
    class Base
      attr_reader :connection, :uri, :version, :verb

      def initialize(connection)
        @verb ||= :get
        @connection = connection
      end

      def call action, params={}
        MWS::Request.new((params.delete(:verb) || verb),
                         uri,
                         action,
                         connection,
                         version,
                         params.except(:request_params),
                         (params[:request_params] || {})).call
      end

      def method_missing(name, *args)
        if self.class::Actions.include?(name)
          self.call(name, *args)
        else
          super
        end
      end
    end
  end
end
