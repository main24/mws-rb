require 'spec_helper'

describe MWS::Request do
  let(:connection) { MWS::Connection.new({
    aws_access_key_id: "access key",
    aws_secret_access_key: "secret key",
    seller_id: "seller id"
  })}

  let(:uri) { "/Products/2011-10-01" }
  let(:action) { :get_products }
  let(:version) { "2011-10-01" }
  let(:params) { { some_parameter: 'some_value' } }
  let(:request_params) { { some_request_parameter: 'some_request_value' } }
  let(:verb) { :get }

  let(:mws_request) { MWS::Request.new(verb, uri, action, connection, version, params, request_params) }

  describe '#call' do
    let(:dummy_request_uri) { "some-uri" }

    subject { mws_request.call }

    before do
      MWS::Query.any_instance.stub(:request_uri).and_return(dummy_request_uri)
      HTTParty.stub(:get).and_return({ code: '200' })
    end

    it 'should call for HTTParty method according to verb' do
      HTTParty.should_receive(:get).with(dummy_request_uri, request_params)

      subject
    end
  end

  describe '#query' do
    subject { mws_request.query }

    it { should be_a MWS::Query }

    it 'should call for MWS::Query.new with proper params' do
      MWS::Query.should_receive(:new).with({
        verb: verb,
        uri: uri,
        host: connection.host,

        aws_access_key_id: connection.aws_access_key_id,
        aws_secret_access_key: connection.aws_secret_access_key,
        seller_id: connection.seller_id,
        action: 'GetProducts',
        version: version,
        params: params
      })

      subject
    end
  end
end
