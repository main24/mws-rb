module MWS
  class Request < Struct.new(:verb, :uri, :action, :connection, :version, :params, :request_params)
    attr_reader :query

    def call
      make_request
    end

    def query
      @query ||= build_query
    end

    protected

      def make_request
        HTTParty.send verb, request_uri, additional_request_params
      end

      def query_params
        params || {}
      end

      def additional_request_params
        request_params || {}
      end

      def request_uri
        query.request_uri
      end

      def build_query
        Query.new({
          verb: verb,
          uri: uri,
          host: connection.host,

          aws_access_key_id: connection.aws_access_key_id,
          aws_secret_access_key: connection.aws_secret_access_key,
          seller_id: connection.seller_id,
          action: action.to_s.camelize,
          version: version,
          params: query_params
        })
      end
  end
end
