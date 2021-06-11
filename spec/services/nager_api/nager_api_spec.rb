require 'rails_helper'

RSpec.describe NagerAPI::Client do
  describe 'api call,' do
    describe '#upcoming_holidays' do
      xit 'returns the three upcoming holidays' do
        allow_any_instance_of(NagerAPI::Client).to receive(:request).with(hash_including(endpoint: '')).and_return {
          [{'date'=>'2000-02-01'}, {'date'=>'2000-03-01'}, {'date'=>'2000-04-01'}, {'date'=>'2000-05-01'}, {'date'=>'2000-06-01'}]
        }
        allow_any_instance_of(NagerAPI::Client).to receive(:current_time).and_return(Time.parse('2000-01-01'))

        client = NagerAPI::Client.new

        expect(client.upcoming_holidays).to eq [{'date'=>'2000-02-01'}, {'date'=>'2000-03-01'}, {'date'=>'2000-04-01'}]
      end
    end
  end
end