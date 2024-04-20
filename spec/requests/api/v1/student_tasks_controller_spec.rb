require 'swagger_helper'

def login_user()
  # Give the login details of a DB-seeded user.
  login_details = {
    user_name: "john",
    password: "password123"
  }

  # Make the request to the login function.
  post '/login', params: login_details

  # Get the token from the response
  json_response = JSON.parse(response.body)
  json_response['token']
end

describe 'StudentTasks API', type: :request do

  before(:each) do
    @token = login_user
  end

  path '/api/v1/student_tasks/list' do
    get 'student tasks list' do
      tags 'StudentTasks'
      produces 'application/json'

      parameter name: 'Authorization', :in => :header, :type => :string

      response '200', 'authorized request' do
        let(:'Authorization') {"Bearer #{@token}"}
        run_test!
      end

      response '401', 'unauthorized request' do
        let(:'Authorization') {"Bearer "}
        run_test!
      end

    end


  end
end



describe 'GET /student_tasks/:id/view' do
  let(:participant) { create(:participant) } # Assuming factories are set up for participant

  before do
    allow(controller).to receive(:authorize_request).and_return(true) # Mock authorization
    # //TODO replace :authorize_request your actual authorization method
  end

  context 'when the participant exists' do
    it 'returns the participant task view' do
      get :view, params: { id: participant.id }, headers: { 'Authorization' => "Bearer #{@token}" }
      expect(response).to have_http_status(:ok)
      expect(json).to include('assignment_name')
      # ... additional checks for each expected attribute
    end
  end

  context 'when the participant does not exist' do
    it 'returns a not found message' do
      get :view, params: { id: 0 }, headers: { 'Authorization' => "Bearer #{@token}" }
      expect(response).to have_http_status(:not_found)
      expect(json['error']).to match(/not found/)
    end
  end
end
