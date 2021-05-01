# frozen_string_literal: true

module ActiveRecord
  class SmartPreloader
    VERSION = '0.1.0'

    def self.call(records, association)
      case association
      when Hash
        association.each do |key, value|
          preloaded_records = call(records, key)
          call(preloaded_records, value)
        end
      when Array
        association.each do |key|
          call(records, key)
        end
      when Symbol, String
        ActiveRecord::Associations::Preloader.new.preload(records, association)
        records.flat_map(&association.to_sym.to_proc).compact
      when CompositeKey
        ActiveRecord::CompositeKeyPreloader.(records, association.association, association.key)
        records.flat_map(&association.association.to_sym.to_proc).compact
      when Proc
        records.select(&association)
      else
        if association.instance_of?(Class) && association.ancestors.include?(ApplicationRecord)
          return records.grep(association)
        end

        raise ArgumentError, "#{association.inspect} was not recognized for preload"
      end
    end

    def initialize(preloads)
      @preloads = preloads
    end

    def call(records)
      self.class.call(records, @preloads)
    end
  end
end
