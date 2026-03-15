class Accounts::SplitRegisterPdfController < AccountsController
  def show
    # would get ledger
    set_param_date
    set_account
    pdf = Pdf::SplitRegister.new(@from,@account,@to)
    send_data pdf.render, filename: "CheckingRegister-#{params[:date]}",
      type: "application/pdf",
      disposition: "inline"
  end

end
