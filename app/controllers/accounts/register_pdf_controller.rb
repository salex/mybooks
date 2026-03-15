class Accounts::RegisterPdfController < AccountsController
  def show
    # would get ledger
    set_param_date
    set_account
    pdf = Pdf::Register.new(@from,@account,@to)
    send_data pdf.render, filename: "CheckingRegister-#{params[:date]}",
      type: "application/pdf",
      disposition: "inline"
  end
 
end
