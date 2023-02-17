require 'active_record'
require 'active_support'

module ActiveRecord
module DateRangeScopes
  extend ActiveSupport::Concern

  module ClassMethods
    ##
    # Defines 3 date range scopes named after the given `name`:
    # - {name}_between
    # - {name}_after
    # - {name}_before
    #
    # By default, uses {name}_at as the column name. Column should be a :datetime (timestamp) column.
    #
    # Examples:
    #
    #   class Book < ActiveRecord::Base
    #     # This defines created_between, created_after, created_before scopes
    #     date_range_scopes :created
    #
    #     # This defines updated_between, updated_after, updated_before scopes
    #     date_range_scopes :updated
    #   end
    #
    #   class Author < ActiveRecord::Base
    #     # You can specify a different column name to use for the scopes, and optionally, any joins
    #     # or other clauses you need to add to the relation.
    #     date_range_scopes :with_any_books_created, ->{ Book.arel_table[:created_at] }, ->(_) { joins(:books) }
    #   end
    #
    #   # This would be the same as:
    #   class Author < ActiveRecord::Base
    #     scope :with_any_books_created_between, ->(after, before) {
    #       with_any_books_created_after(after).
    #       with_any_books_created_before(before)
    #     }
    #     scope :with_any_books_created_after, ->(date_or_time) {
    #       next unless date_or_time
    #
    #       joins(:books).
    #       where(
    #         Book.arel_table[:created_at].gteq( time_or_beginning_of_day(date_or_time) )
    #       )
    #     }
    #     scope :with_any_books_created_before, ->(date_or_time) {
    #       …
    #     }
    #   end
    #
    def date_range_scopes(
      name,
      arel_attr = -> { arel_table[:"#{name}_at"] },
      relation = :itself
    )
      relation = relation.to_proc

      scope :"#{name}_between", ->(after, before) {
        public_send(:"#{name}_after", after).
        public_send(:"#{name}_before", before)
      }
      scope :"#{name}_after",   ->(date_or_time) {
        next unless date_or_time

        instance_eval(&relation).
        where(
          arel_attr.().gteq( time_or_beginning_of_day(date_or_time) )
        )
      }
      scope :"#{name}_before", ->(date_or_time) {
        next unless date_or_time

        instance_eval(&relation).
        where(
          arel_attr.().lteq( time_or_end_of_day(date_or_time) )
        )
      }

      scope :"#{name}_on", ->(date_or_time) {
        public_send(:"#{name}_between",
          date_or_time.in_time_zone.beginning_of_day,
          date_or_time.in_time_zone.end_of_day
        )
      }
    end

    def time_or_end_of_day(date_or_time)
      if date_or_time.is_a?(Date)
        date_or_time.in_time_zone.end_of_day
      else
        date_or_time.in_time_zone
      end
    end

    def time_or_beginning_of_day(date_or_time)
      if date_or_time.is_a?(Date)
        date_or_time.in_time_zone.beginning_of_day
      else
        date_or_time.in_time_zone
      end
    end

    ##
    # Delegates the date filter scopes to an association (requires the scopes to already be
    # defined there in the `to` model using `date_range_scopes`).
    #
    # This uses `Relation.merge` to merge the scope on the associated model, allowing you to reuse
    # existing scopes on other models. But since these scopes are local (to the model in which you
    # call `delegate_date_range_scopes`), the query returns instances of the local model rather than
    # instances of the associated model.
    #
    # Unlike date_range_scopes, where you specify which *column* to operate on, this lets you specify
    # which *scope* to delegate to in the target (`to`) model.  If `scope` not specified, uses the
    # same scope name as in the source model, removing `{target}s_` prefix if there is one.
    #
    # Example:
    #
    #   class Book < ActiveRecord::Base
    #     date_range_scopes :created
    #   end
    #
    #   class Author < ActiveRecord::Base
    #     # Delegates to Book.created* scopes by default
    #     delegate_date_range_scopes :books_created,          ->(_) { joins(:books) }, to: Book
    #     # Explicitly tells it to delegate Author.with_any_books_written_* to Book.created_
    #     delegate_date_range_scopes :with_any_books_written, ->(_) { joins(:books) }, to: Book, scope: :created
    #   end
    #
    #   Author.with_any_books_written_before('1970-01-01')
    #
    def delegate_date_range_scopes(
      local_name,
      relation = :itself,
      to:,
      scope: nil
    )
      relation = relation.to_proc
      target_model = to
      name_on_target = scope || local_name.to_s.sub(/^#{target_model.model_name.plural}_/, '')

      scope(:"#{local_name}_between", ->(after, before) {
        public_send(:"#{local_name}_after", after).
        public_send(:"#{local_name}_before", before)
      })
      scope(:"#{local_name}_after",   ->(date_or_time) {
        next unless date_or_time

        instance_eval(&relation).
        merge(
          target_model.public_send(:"#{name_on_target}_after", date_or_time)
        )
      })
      scope(:"#{local_name}_before", ->(date_or_time) {
        next unless date_or_time

        instance_eval(&relation).
        merge(
          target_model.public_send(:"#{name_on_target}_before", date_or_time)
        )
      })
    end
  end
end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::DateRangeScopes
end
