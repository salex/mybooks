/ \[\:(\w+)\]
=turbo_frame_tag "entries"
  div.p-2.m-2.border.border-blue-500
    span.ml-4
      strong Reconciled:&nbsp;
      = to_money(@checking_balance.reconciled_balance)
    span.ml-4
      strong Cleared:&nbsp;
      = to_money(@checking_balance.cleared_balance)
    span.ml-4
      strong Uncleared:&nbsp;
      = to_money(@checking_balance.uncleared_balance)
    span.ml-4
      strong Ending:&nbsp;
      = to_money(@checking_balance.balance)
    span.ml-4
      strong Bank/Closing:&nbsp;
      = to_money(@checking_balance.closing_balance)
    span.ml-4
      strong Difference:&nbsp;
      = to_money(@checking_balance.closing_balance - @checking_balance.balance )

  .grid.gap-16.grid-cols-2
    div
      turbo-frame-tag id="cleared"
        table.classic.w-full
          caption.font-bold.italic Cleared Checking Account Transactions
          - @checking_balance.cleared_entries.each do |x|
            tr
              td.w-28 = x.post_date
              td.goldey.w-6.text-center  = button_to(x.reconciled,
                split_unclear_report_path(x,closing_date:@checking_balance.closing_date,closing_balance:@checking_balance.closing_balance))

              td = x.numb
              td.w-22 = x.description
              td.text-right = to_money(x.amount)
          tr
            td.strong.text-right[colspan="4"] Cleared Balance
            td.strong.text-right = to_money(@checking_balance.cleared_balance)

    div
      turbo-frame-tag id="uncleared"
        table.classic.w-full
          caption.font-bold.italic Uncleared Checking Account Transactions
          - @checking_balance.uncleared_entries.each do |x|
            tr
              td.w-28 = x.post_date
              td.goldey.w-6.text-center  = button_to(x.reconciled,
                split_clear_report_path(x,closing_date:@checking_balance.closing_date,closing_balance:@checking_balance.closing_balance))


              td = x.numb
              td.w-22 = x.description
              td.text-right = to_money(x.amount)
          tr
            td.strong.text-right[colspan="4"] Uncleared Balance
            td.strong.text-right = to_money(@checking_balance.uncleared_balance)
