require "application_system_test_case"

class AuditsTest < ApplicationSystemTestCase
  setup do
    @audit = audits(:one)
  end

  test "visiting the index" do
    visit audits_url
    assert_selector "h1", text: "Audits"
  end

  test "should create audit" do
    visit audits_url
    click_on "New audit"

    fill_in "Balance", with: @audit.balance
    fill_in "Book", with: @audit.book_id
    fill_in "Client", with: @audit.client_id
    fill_in "Date from", with: @audit.date_from
    fill_in "Outstanding", with: @audit.outstanding
    fill_in "Settings", with: @audit.settings
    click_on "Create Audit"

    assert_text "Audit was successfully created"
    click_on "Back"
  end

  test "should update Audit" do
    visit audit_url(@audit)
    click_on "Edit this audit", match: :first

    fill_in "Balance", with: @audit.balance
    fill_in "Book", with: @audit.book_id
    fill_in "Client", with: @audit.client_id
    fill_in "Date from", with: @audit.date_from
    fill_in "Outstanding", with: @audit.outstanding
    fill_in "Settings", with: @audit.settings
    click_on "Update Audit"

    assert_text "Audit was successfully updated"
    click_on "Back"
  end

  test "should destroy Audit" do
    visit audit_url(@audit)
    click_on "Destroy this audit", match: :first

    assert_text "Audit was successfully destroyed"
  end
end
