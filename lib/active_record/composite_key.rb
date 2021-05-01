# frozen_string_literal: true
module ActiveRecord
  class CompositeKey
    attr_reader :association, :key

    def initialize(association, key)
      @association = association
      @key = key
    end
  end
end
