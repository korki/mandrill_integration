require 'spec_helper'

describe MandrillEndpoint do

  let(:payload) {
    '{"request_id": "12e12341523e449c3000001",
      "parameters": {
          "mandrill_api_key":"abc123"},
      "email": {
        "to": "spree@example.com",
        "from": "spree@example.com",
        "subject": "Order R123456 was shipped!",
        "template": "order_confirmation",
        "variables": {
          "customer.name": "John Smith",
          "order.total": "100.00",
          "order.tracking": "XYZ123"
        }
      }
    }'
 }

  it "should respond to POST send_email" do
    VCR.use_cassette('mandrill_send') do
      post '/send_email', payload, auth
      expect(last_response.status).to eql 200
      expect(json_response["request_id"]).to eql "12e12341523e449c3000001"
      expect(json_response["summary"]).to match /Sent 'Order R123456 was shipped!' email/
    end
  end

  it "should respond to POST send_email with multiple emails" do
    VCR.use_cassette('mandrill_send_to_multi') do
      parsed = JSON.parse(payload)
      addrs = "spree@example.com;spree2@example.com;spree3@example.com"
      parsed['email']['to'] = addrs
      post '/send_email', parsed.to_json, auth
      expect(last_response.status).to eql 200
      expect(json_response["request_id"]).to eql "12e12341523e449c3000001"
      expect(json_response["summary"]).to match /Sent 'Order R123456 was shipped!' email/
      expect(json_response["summary"]).to include addrs
    end
  end
end

