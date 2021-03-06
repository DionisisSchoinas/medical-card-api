require 'rails_helper'

RSpec.describe 'Doctor Appointments API' do
  # Initialize the test data
  let!(:user) { create(:user)}
  let!(:user2) { create(:user)}
  let!(:doctor) { create(:doctor, user_id: user.id) }
  let!(:patient) { create(:patient, user_id: user2.id) }
  let!(:appointments) { create_list(:appointment, 30, doctor_id: doctor.id, patient_id: patient.id) }
  let(:doctor_id) { doctor.id }
  let(:patient_id) { patient.id }
  let(:id) { appointments.first.id }
  # authorize request
  let(:headers) { valid_headers }

  # Test suite for GET /doctors/:doctor_id/appointments_simple
  describe 'GET /doctors/:doctor_id/appointments_simple' do
    context 'with default page and per_page values' do
      before { get "/doctors/#{doctor_id}/appointments_simple", params: {}, headers: headers }

      context 'when doctor exists' do
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns 1st page of doctor\'s appointments (20 appointments) only with dates and id' do
          expect(json['appointments'].size).to eq(20)
        end
      end

      context 'when doctor does not exist' do
        let(:doctor_id) { 0 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Doctor/)
        end
      end
    end

    context 'with page=2 and per_page=20' do
      before { get "/doctors/#{doctor_id}/appointments_simple?page=2&per_page=20", params: {}, headers: headers }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns 2nd page of doctor\'s appointments (10 appointments) only with dates and id' do
          expect(json['appointments'].size).to eq(10)
        end
    end
  end

  # Test suite for GET /doctor/appointments
  describe 'GET /doctor/appointments' do
    context 'with default page and per_page values' do
      before { get "/doctor/appointments", params: {}, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 1st page of doctor\'s appointments (20 appointments)' do
        expect(json['appointments'].size).to eq(20)
      end
    end

    context 'with page=2 and per_page=20' do
      before { get "/doctor/appointments?page=2&per_page=20", params: {}, headers: headers }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns 2nd page of doctor\'s appointments (10 appointments)' do
          expect(json['appointments'].size).to eq(10)
        end
    end
  end

  # Test suite for GET /doctor/appointments/:id
  describe 'GET /doctor/appointments/:id' do
    before { get "/doctor/appointments/#{id}", params: {}, headers: headers }

    context 'when doctor appointment exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the appointment' do
        expect(json['appointment']['id']).to eq(id)
      end
    end

    context 'when doctor appointment does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Appointment/)
      end
    end
  end

  # Test suite for GET /doctor/appointments_simple
  describe 'GET /doctor/appointments_simple' do
    context 'with default page and per_page values' do
      before { get "/doctor/appointments_simple", params: {}, headers: headers }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns 1st page of doctor\'s appointments (20 appointments) with dates and id' do
        expect(json['appointments'].size).to eq(20)
      end
    end

    context 'with page=2 and per_page=20' do
      before { get "/doctor/appointments_simple?page=2&per_page=20", params: {}, headers: headers }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns 2nd page of doctor\'s appointments (10 appointments) only with dates and id' do
          expect(json['appointments'].size).to eq(10)
        end
    end
  end
end
