class Author < ActiveRecord::Base
  has_many :books

#  date_range_scopes :with_any_books_created,
#    ->{ Book.arel_table[:created_at] },
#    ->(_) { joins(:books) }

  scope :with_any_books_created_between, ->(after, before) {
    with_any_books_created_after(after).
    with_any_books_created_before(before)
  }
  scope :with_any_books_created_after, ->(date_or_time) {
    next unless date_or_time

    joins(:books).
    where(
      Book.arel_table[:created_at].gteq( time_or_beginning_of_day(date_or_time) )
    )
  }
  scope :with_any_books_created_before, ->(date_or_time) {
    next unless date_or_time

    joins(:books).
    where(
      Book.arel_table[:created_at].lteq( time_or_end_of_day(date_or_time) )
    )
  }
end
