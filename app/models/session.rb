class Session < ApplicationRecord
  belongs_to :user

  # an idea that didn't work session reloaded each time
  # used a $variable for 
  # attribute :last_upload
  # attribute :original_filename
end
