
class AuditsController < ApplicationController
  # allow_unauthenticated_access
  before_action :set_audit, only: %i[ show edit  update destroy print]

  # GET /audits
  def index
    @audits = Current.book.audits.all
  end

  # GET /audits/1
  def show
  end

  # GET /audits/new
  def new
    puts "getting las audit"
    last_audit = Audit.last


    @audit = Audit.new(settings:last_audit.settings)
  end

  # GET /audits/1/edit
  def edit
    puts "IN PLAIN EDIT #{@audit.present?}"
  end

  # POST /audits
  def create
    @audit = Audit.new(audit_params)

    if @audit.save
      redirect_to @audit, notice: "Audit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /audits/1
  def update
    # puts " GOTO AUDIT CONTROLLER UPDAE #{audit_params} keys }"
    # redirect_to @audit, notice: "Audit was successfully updated.", status: :see_other

    if @audit.update(audit_params)
      redirect_to @audit, notice: "Audit was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /audits/1
  def destroy
    @audit.destroy!
    redirect_to audits_path, notice: "Audit was successfully destroyed.", status: :see_other
  end

  # GET /audits/1/print
  def print
    # This in not a normal rails process
    # @audit is set in set_audit and the template is loaded
    # from there, the template, and helpers take over
    # @audit  = @audit.as_json
    # puts "AUDIT HASD #{@audit}"
    render template: 'vfw/audit/print'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_audit
      @audit = Audit.find(params.expect(:id))
      puts "IN SET AUDIT @audit.id is #{@audit.id}"
    end

    # Only allow a list of trusted parameters through.
    def audit_params
      params.expect(audit: [ :client_id, :book_id, :date_from, :balance, :outstanding, :settings ])
    end
end

