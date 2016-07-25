describe 'integration' do
  describe Rubyflare, order: :defined do
    # Given I have valid Cloudflare credentials
    # When I create a Rubyflare instance
    # And get my Cloudflare user details
    # Then I should have valid response
    context 'given I have valid Cloudflare credentials' do
      let(:email)   { ENV['CLOUDFLARE_EMAIL'] }
      let(:api_key) { ENV['CLOUDFLARE_API_KEY'] }

      context 'when I create a Rubyflare instance' do
        let(:connection) { described_class.connect_with(email, api_key) }

        context 'and GET my Cloudflare user details' do

          it 'should return a valid response' do
            response = connection.get('user')
            expect(response).to be_successful
          end
        end

        context 'and update(PATCH) my user details' do

          it 'should return a valid response' do
            response = connection.patch('user', { first_name: ENV['RUBYFLARE_TEST_FIRST_NAME'] || 'Trevor' })
            expect(response).to be_successful
          end
        end

        context 'and create(POST) a new zone' do

          it 'should return a valid response' do
            response = connection.post('zones', { name: ENV['RUBYFLARE_TEST_DOMAIN'] || 'supercooldomain.com' })
            expect(response).to be_successful
          end
        end

        context 'and remove(DELETE) a zone' do

          it 'should return a valid response' do
            domain_zone = connection.get('zones', { name: ENV['RUBYFLARE_TEST_DOMAIN'] || 'supercooldomain.com' })
            response = connection.delete("zones/#{domain_zone.result[:id]}")
            expect(response).to be_successful
          end
        end
      end
    end
  end
end
