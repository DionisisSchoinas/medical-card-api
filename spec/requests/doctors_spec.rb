require 'rails_helper'

RSpec.describe 'Doctors API' do
  # Initialize the test data
  let!(:user) { create(:user)}
  let!(:user2) { create(:user)}
  let!(:user3) { create(:user)}
  let!(:doctor) { create(:doctor, user_id: user.id) }
  let!(:doctor2) { create(:doctor, user_id: user2.id) }
  let!(:doctor3) { create(:doctor, user_id: user3.id) }
  let(:id) { doctor.id }
  # authorize request
  let(:headers) { valid_headers }

  # Test suite for GET /doctor
  describe 'GET /doctor' do
    before { get "/doctor", params: {}, headers: headers }

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns logged in doctor' do
      expect(json['doctor']['id']).to eq(id)
    end
  end

  # Test suite for GET /doctors
  describe 'GET /doctors' do
    context 'with default page and per_page values' do
      before { get "/doctors", params: {}, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 1st page of doctors (3 doctors)' do
        expect(json['doctors'].size).to eq(3)
      end
    end

    context 'with page=2 and per_page=2' do
      before { get "/doctors?page=2&per_page=2", params: {}, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 2nd page of doctors (1 doctor)' do
        expect(json['doctors'].size).to eq(1)
      end
    end
  end

  # Test suite for GET /doctors/:id
  describe 'GET /doctors/:id' do
    before { get "/doctors/#{id}", params: {}, headers: headers }

    context 'when doctor exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the doctor' do
        expect(json['doctor']['id']).to eq(id)
      end
    end

    context 'when doctor does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Doctor/)
      end
    end
  end

  # Test suite for POST /doctors
  describe 'POST /doctors' do
    context 'when request attributes are valid' do
      let(:user4) { create(:user) }
      let(:headers) do
        {
          AuthorizationToken: token_generator(user4.id),
          "Content-Type" => "application/json"
        }
      end

      let(:valid_attributes) do
        {
          doctor: {
            speciality: 'speciality1',
            office_address: 'office_address1',
            phone: 'phone1',
            email: 'mail@gmail.com',
            cost: 50,
          },
          image_base64: 'image_to_base_64'
        }.to_json
      end

      before { post "/doctors", params: valid_attributes, headers: headers }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns success message' do
        expect(response.body).to match(/Doctor account created successfully/)
      end
    end

    context 'when an invalid request' do
      before { post "/doctors", params: {}, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/param is missing or the value is empty:/)
      end
    end

    context 'when user already is a doctor' do
      let(:valid_attributes) do
        {
          doctor: {
            user_id: doctor.user_id
          },
          image_base64: 'image_to_base_64'
        }.to_json
      end
      before { post "/doctors", params: valid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/User has already been taken/)
      end
    end
  end

  # Test suite for PUT /doctor
  describe 'PUT /doctor' do
    context 'when the doctor exists' do
      let(:valid_attributes) do
        {
          doctor: {
            phone: 'phone2'
          }
        }.to_json
      end
      before { put "/doctor", params: valid_attributes, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the record' do
        expect(response.body).to match(/Doctor account updated successfully/)
      end
    end
  end
end
