require "test_helper"

class BankTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank_transaction = bank_transactions(:one)
  end

  test "should get index" do
    get bank_transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_transaction_url
    assert_response :success
  end

  test "should create bank_transaction" do
    assert_difference("BankTransaction.count") do
      post bank_transactions_url, params: { bank_transaction: { amount: @bank_transaction.amount, book_id: @bank_transaction.book_id, client_id: @bank_transaction.client_id, description: @bank_transaction.description, post_date: @bank_transaction.post_date, split_id: @bank_transaction.split_id, type: @bank_transaction.type } }
    end

    assert_redirected_to bank_transaction_url(BankTransaction.last)
  end

  test "should show bank_transaction" do
    get bank_transaction_url(@bank_transaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_transaction_url(@bank_transaction)
    assert_response :success
  end

  test "should update bank_transaction" do
    patch bank_transaction_url(@bank_transaction), params: { bank_transaction: { amount: @bank_transaction.amount, book_id: @bank_transaction.book_id, client_id: @bank_transaction.client_id, description: @bank_transaction.description, post_date: @bank_transaction.post_date, split_id: @bank_transaction.split_id, type: @bank_transaction.type } }
    assert_redirected_to bank_transaction_url(@bank_transaction)
  end

  test "should destroy bank_transaction" do
    assert_difference("BankTransaction.count", -1) do
      delete bank_transaction_url(@bank_transaction)
    end

    assert_redirected_to bank_transactions_url
  end
end
