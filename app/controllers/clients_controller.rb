class ClientsController < ApplicationController
  # allow_unauthenticated_access

  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients
  def index
    @clients = Client.all
  end

  # GET /clients/1
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy!
    redirect_to clients_path, notice: "Client was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.expect(client: [ :name, :acct, :address, :city, :state, :zip, :phone, :subdomain, :domain ])
    end
end
