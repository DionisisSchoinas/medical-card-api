class AppointmentsController < ApplicationController
  before_action :set_patient
  before_action :set_appointment, only: [:show, :destroy]

  # GET patients/:patient_id/appointments
  def index
    appointments = @patient.appointments
    json_response(appointments, :ok, ['doctor', 'patient.user'])
  end

  # POST patients/:patient_id/appointments
  def create
    new_appointment = @patient.appointments.create!(appointment_params)
    #----------------
    # => Send push notification to devices
    #----------------
    json_response(new_appointment, :created, ['doctor', 'patient.user'])
  end

  # GET patients/:patient_id/appointments/:id
  def show
    json_response(@appointment, :ok, ['doctor', 'patient.user'])
  end

  # DELETE patients/:patient_id/appointments/:id
  def destroy
    @appointment.destroy
    #----------------
    # => Send push notification to devices
    #----------------
    head :no_content
  end

  private

  def appointment_params
    params.permit(:appointment_date, :duration_minutes, :doctor_id)
  end

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def set_appointment
    @appointment = @patient.appointments.find_by!(id: params[:id]) if @patient
  end
end
