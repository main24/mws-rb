require 'spec_helper'

describe MWS::API::Base do
  let(:connection) { MWS::Connection.new({
    aws_access_key_id: "access key",
    aws_secret_access_key: "secret key",
    seller_id: "seller id"
  })}

  let(:base) { MWS::API::Base.new(connection) }

  it "hould receive a connection object" do
    base.connection.should eq(connection)
  end

  it "should respond to .call" do
    base.should respond_to(:call)
  end

  it "should respond to :uri and :version and :verb" do
    base.should respond_to(:uri)
    base.should respond_to(:version)
    base.should respond_to(:verb)
  end

  it "should set :verb to :get as default" do
    base.verb.should eq(:get)
  end

  describe "method_missing to call actions" do
    let(:test_api) { TestApi.new(connection) }
    let(:http_response) { { code: '200' } }
    before { HTTParty.stub(:get).and_return(http_response) }

    class TestApi < MWS::API::Base
      Actions = [:test_action]
      def initialize(connection)
        @uri = "/Products/2011-10-01"
        @version = "2011-10-01"
        super(connection)
      end
    end

    it "should not raise exception if Actions contain the action name" do
      expect {test_api.test_action}.to_not raise_error
    end

    it "should raise exception if Actions do not contain the action name" do
      expect {test_api.action_not_found}.to raise_error
    end

    describe 'action' do
      context 'when action http verb is not defined in the initializer' do
        it 'should call for MWS::Request with default :get verb' do
          mws_request = double
          MWS::Request.should_receive(:new).with(:get, "/Products/2011-10-01", :test_action, test_api.connection, "2011-10-01", {}, {}).and_return(mws_request)
          mws_request.should_receive(:call).and_return(http_response)

          test_api.test_action
        end
      end

      context 'when action http verb defined in params' do
        it 'should call for MWS::Request with verb defined in params' do
          mws_request = double
          MWS::Request.should_receive(:new).with(:post, "/Products/2011-10-01", :test_action, test_api.connection, "2011-10-01", {}, {}).and_return(mws_request)
          mws_request.should_receive(:call).and_return(http_response)

          test_api.test_action(verb: :post)
        end
      end

      context 'when action http verb defined in the initializer' do
        class TestApiWithVerb < MWS::API::Base
          Actions = [:test_action]
          def initialize(connection)
            @uri = "/Products/2011-10-01"
            @version = "2011-10-01"
            @verb = :post
            super(connection)
          end
        end

        let(:test_api) { TestApiWithVerb.new(connection) }

        it 'should call for MWS::Request with defined verb' do
          mws_request = double
          MWS::Request.should_receive(:new).with(:post, "/Products/2011-10-01", :test_action, test_api.connection, "2011-10-01", {}, {}).and_return(mws_request)
          mws_request.should_receive(:call).and_return(http_response)

          test_api.test_action
        end
      end
    end
  end
end
