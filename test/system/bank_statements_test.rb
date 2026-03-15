require "application_system_test_case"

class BankStatementsTest < ApplicationSystemTestCase
  setup do
    @bank_statement = bank_statements(:one)
  end

  test "visiting the index" do
    visit bank_statements_url
    assert_selector "h1", text: "Bank statements"
  end

  test "should create bank statement" do
    visit bank_statements_url
    click_on "New bank statement"

    fill_in "Beginning balance", with: @bank_statement.beginning_balance
    fill_in "Book", with: @bank_statement.book_id
    fill_in "Client", with: @bank_statement.client_id
    fill_in "Ending balance", with: @bank_statement.ending_balance
    fill_in "Json", with: @bank_statement.json
    fill_in "Reconciled date", with: @bank_statement.reconciled_date
    fill_in "Statement date", with: @bank_statement.statement_date
    fill_in "Summary", with: @bank_statement.summary
    click_on "Create Bank statement"

    assert_text "Bank statement was successfully created"
    click_on "Back"
  end

  test "should update Bank statement" do
    visit bank_statement_url(@bank_statement)
    click_on "Edit this bank statement", match: :first

    fill_in "Beginning balance", with: @bank_statement.beginning_balance
    fill_in "Book", with: @bank_statement.book_id
    fill_in "Client", with: @bank_statement.client_id
    fill_in "Ending balance", with: @bank_statement.ending_balance
    fill_in "Json", with: @bank_statement.json
    fill_in "Reconciled date", with: @bank_statement.reconciled_date
    fill_in "Statement date", with: @bank_statement.statement_date
    fill_in "Summary", with: @bank_statement.summary
    click_on "Update Bank statement"

    assert_text "Bank statement was successfully updated"
    click_on "Back"
  end

  test "should destroy Bank statement" do
    visit bank_statement_url(@bank_statement)
    click_on "Destroy this bank statement", match: :first

    assert_text "Bank statement was successfully destroyed"
  end
end
