# app/controllers/viisp_controller.rb

class ViispController < ApplicationController
  def authenticate
    ticket = VIISP::Auth.ticket

    # Redirect the user to the VIISP portal
    redirect_to VIISP::Auth.portal_endpoint(ticket)
  end

  def callback
    # Handle the callback from VIISP after successful authentication
    ticket = params[:ticket]
    identity = VIISP::Auth.identity(ticket: ticket, include_source_data: true)

    # Process identity data as needed (e.g., store in the database, log in the user)
    # ...

    # Redirect or render as needed
    # ...
  end
end
