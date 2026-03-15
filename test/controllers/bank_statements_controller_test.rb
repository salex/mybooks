require "test_helper"

class BankStatementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank_statement = bank_statements(:one)
  end

  test "should get index" do
    get bank_statements_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_statement_url
    assert_response :success
  end

  test "should create bank_statement" do
    assert_difference("BankStatement.count") do
      post bank_statements_url, params: { bank_statement: { beginning_balance: @bank_statement.beginning_balance, book_id: @bank_statement.book_id, client_id: @bank_statement.client_id, ending_balance: @bank_statement.ending_balance, json: @bank_statement.json, reconciled_date: @bank_statement.reconciled_date, statement_date: @bank_statement.statement_date, summary: @bank_statement.summary } }
    end

    assert_redirected_to bank_statement_url(BankStatement.last)
  end

  test "should show bank_statement" do
    get bank_statement_url(@bank_statement)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_statement_url(@bank_statement)
    assert_response :success
  end

  test "should update bank_statement" do
    patch bank_statement_url(@bank_statement), params: { bank_statement: { beginning_balance: @bank_statement.beginning_balance, book_id: @bank_statement.book_id, client_id: @bank_statement.client_id, ending_balance: @bank_statement.ending_balance, json: @bank_statement.json, reconciled_date: @bank_statement.reconciled_date, statement_date: @bank_statement.statement_date, summary: @bank_statement.summary } }
    assert_redirected_to bank_statement_url(@bank_statement)
  end

  test "should destroy bank_statement" do
    assert_difference("BankStatement.count", -1) do
      delete bank_statement_url(@bank_statement)
    end

    assert_redirected_to bank_statements_url
  end
end
