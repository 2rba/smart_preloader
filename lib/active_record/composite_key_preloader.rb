# frozen_string_literal: true

module ActiveRecord
  # Modified ActiveRecord::Associations::Preloader::Association
  class CompositeKeyPreloader
    # The CompositeKeyPreloader does the same as default rails preloader ( ActiveRecord::Associations::Preloader )
    # The difference: CompositeKeyPreloader allows to reference another table by multiple columns
    #
    # @param [Array<ActiveModel>] records Collection of active record models
    # @param [Symbol] association ActiveRecord model association name to preload
    # @param [Array<Symbol>] composite_key Array of primary_keys, defines how association should be loaded.
    #   Default Rails implementation does not allow to specify composite key (multi-column key)
    def self.call(records, association, composite_key)
      records_for_preload = records.reject { |record| record.association(association).loaded? }
      return if records_for_preload.blank?

      assoc = records.first.association(association)
      new(assoc.klass, records, assoc.reflection, composite_key).run
    end

    def initialize(klass, owners, reflection, composite_key)
      @klass         = klass
      @owners        = owners
      @reflection    = reflection
      @preloaded_records = []
      @composite_key = composite_key
    end

    def run
      records = load_records

      owners.each do |owner|
        owner_key = @composite_key.map { |key_name| owner[key_name] }
        associate_records_to_owner(owner, records[owner_key] || [])
      end
    end

    protected

    attr_reader :owners, :reflection, :klass

    private

    def associate_records_to_owner(owner, records)
      association = owner.association(reflection.name)
      association.loaded!
      raise 'no tested yet' if reflection.collection?

      association.target = records.first unless records.empty?
    end

    def owner_keys
      @owner_keys ||= owners_by_key.keys
    end

    def owners_by_key
      unless defined?(@owners_by_key)
        @owners_by_key = owners.each_with_object({}) do |owner, h|
          key = @composite_key.map { |key_name| owner[key_name] }
          h[key] = owner if key
        end
      end
      @owners_by_key
    end

    def load_records
      return {} if owner_keys.empty?

      # Some databases impose a limit on the number of ids in a list (in Oracle it's 1000)
      # Make several smaller queries if necessary or make one query if the adapter supports it
      slices = owner_keys.each_slice(klass.connection.in_clause_length || owner_keys.size)
      @preloaded_records = slices.flat_map do |slice|
        records_for(slice)
      end
      @preloaded_records.group_by do |record|
        @composite_key.map { |key_name| record[key_name] }
      end
    end

    def records_for(ids)
      composed_id_rows = ids.map { |multiple_ids| "ROW(#{multiple_ids.map(&:to_i).join(',')})" }.join(', ')
      klass.scope_for_association.where("(#{@composite_key.join(', ')}) IN (#{composed_id_rows})")
    end
  end
end
