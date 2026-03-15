
div[data-controller="remoteUpdate toggle " data-toggle-class="hidden"]

  .grid.grid-cols-4.gap-8.mt-2
    div.col-span-1
      div.strong.align-top Checking Acct Balances
      span.blue-link[data-action="click->toggle#toggle"]
          i.fa.fa-question-circle
          i Help
    div.col-span-1
      strong Closing Date 
      = text_field_tag :closing_date, @checking_balance.closing_date,placeholder:'Pick Date',
        data:{controller:'flatpickr',target:'remoteUpdate.closing_date',class:""}
    div.col-span-1
      strong Closing Balance 
      = text_field_tag :closing_balance,to_money( @checking_balance.closing_balance),placeholder:'Enter Balance',
        data:{remoteUpdate_target:'closing_balance',class:""}
    div.text-right.col-span-1
      button[class="#{btn_sm_blue}" data-action="click->remoteUpdate#rebalance"] Refresh

  .hidden.p-2[data-toggle-target="content"]
    p This page will display balances on a closing date (any input date or defaults to Today). You can use it to periodically check you checkbook balance with the bank balance. If you enter a Closing Balance it will display any difference. If you don't enter a closing balance it will display a negative balance that should be your bank balance on that date.
    ul.classic.ml-4
      li Reconciled balance: The balance of all reconciled Checking account entries on the closure date.
      li Cleared Balance: The balance of all Checking account entries that have been cleared but not reconciled.
      li Uncleared Balance: The balance of all Checking account entries that have not been cleared (new).
      li Ending Balance: Your checking account balance on the Closing date. Sum of the Reconciled, Cleared and Uncleared balances.
      li Bank/Closing balance:  The closing balance you optionally entered.
      li Difference: difference between the Closing balance and ending balance. Should be Zero if a Closing balance was entered.

    p All Cleared and Uncleared entries are listed in a table.
    p You can Clear or Unclear any Entry by clicking on the 'n' in uncleared table and 'c' in the cleared table.
  #ajax_balance
    div 
      = render partial: 'reports/balance'
