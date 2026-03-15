class Entries::DuplicateController < ApplicationController

  def show
    dup_entry = Current.book.entries.find_by(id:params[:id])
    if dup_entry.blank?
      redirect_to( accounts_path, alert:'Entry not found for Current Book')
    else
      # NOTUSED anymore new bank transaction have ni fit-id
      if params[:refid].present?
        if dup_entry.splits.length > 2
          redirect_to latest_ofxes_path, alert:'Sorry, you can\'t duplicate entries with more than 2 splits from Bank Transactions. Deplicate it in the ledger.'
        else
          bank = Current.book.bank_transactions.find_by(fit_id:params[:refid])
          @entry = dup_entry.duplicate_with_bank(bank)
        end
      else
        @entry = dup_entry.duplicate
      end
      render template:'entries/new'
    end
  end

end
