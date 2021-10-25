# frozen_string_literal: true

class BaseService
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
end
