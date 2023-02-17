# ActiveRecord Date Range Scopes

Simply add a line like this within your ActiveRecord model:
```ruby
  date_range_scopes :created
```

… and it will defines 3 date range scopes named after the given scope `name`:
- `{name}_between`
- `{name}_after`
- `{name}_before`

## Usage

### date_range_scopes

Simple example:

```ruby
class Book < ActiveRecord::Base
  # This defines created_between, created_after, created_before scopes
  date_range_scopes :created

  # This defines updated_between, updated_after, updated_before scopes
  date_range_scopes :updated
end

Book.created_between(3.years.ago, 1.year.ago)
Book.created_between('2020-01-01', '2020-01-31')
Book.created_after(1.week.ago)
Book.created_before(1.day.ago)
```

By default, uses `{name}_at` as the column name. Column should be a `:datetime` (timestamp) column.

But if the defaults aren't what you need, it is fully customizable:
- You can give the scopes any name prefix you want
- You can specify a different column name to use for the scopes
- You can optionally add any joins or other clauses you need to add to the relation.

```ruby
class Book < ActiveRecord::Base
  # This creates is_between, is_after, is_before scopes
  date_range_scopes :is, ->{ arel_table[:created_at] },
end
```

```ruby
class Author < ActiveRecord::Base
  date_range_scopes :with_any_books_created,
    ->{ Book.arel_table[:created_at] },
    ->(_) { joins(:books) }
end
```

# This would be the same as writing it out long-hand:
```ruby
class Author < ActiveRecord::Base
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
```

### delegate_date_range_scopes

Delegates the date filter scopes to an association (requires the scopes to already be
defined there in the `to` model using `date_range_scopes`).

This uses `Relation.merge` to merge the scope on the associated model, allowing you to reuse
existing scopes on other models. But since these scopes are local (to the model in which you
call `delegate_date_range_scopes`), the query returns instances of the local model rather than
instances of the associated model.

Unlike date_range_scopes, where you specify which *column* to operate on, this lets you specify
which *scope* to delegate to in the target (`to`) model.  If `scope` not specified, uses the
same scope name as in the source model, removing `{target}s_` prefix if there is one.

Example:

```ruby
class Book < ActiveRecord::Base
  date_range_scopes :created
end

class Author < ActiveRecord::Base
  # Delegates to Book.created* scopes by default
  delegate_date_range_scopes :books_created,          ->(_) { joins(:books) }, to: Book
  # Explicitly tells it to delegate Author.with_any_books_written_* to Book.created_
  delegate_date_range_scopes :with_any_books_written, ->(_) { joins(:books) }, to: Book, scope: :created
end

Author.with_any_books_written_before('1970-01-01')
```



## Features

- Makes it very easy to define date range scopes
- Lets you add scopes that are based on associated (join) records
- If `nil` is passed to any of these scopes, the scope simply has no effect, rather than raising an error. This is useful if you have lots of filters that your users may or may not provide any value for.
- Handles time zones correctly: calls `in_time_zone` on strings/dates that are passed in
- If a date is passed in, it is converted to `beginning_of_day`/`end_of_day` depending on whether it is used in an `_after`/`_before` scope, respectively
- It even lets you mix dates and times in an intuitive way: `Model.created_between(1.week.ago, Date.today)`

## Comparison with other date range gems

### [date_supercharger](https://github.com/simon0191/date_supercharger) ([meat](https://github.com/simon0191/date_supercharger/blob/master/lib/date_supercharger/method_definer.rb))
- It [_automatically_ adds scopes](https://github.com/simon0191/date_supercharger/blob/master/lib/date_supercharger/matcher.rb#L25) for every `datetime`/`date` column (PR welcome for an optional module that you can include to get this behavior); `active_record_date_range_scopes` requires explicitly adding scopes, provides a macro that makes it easy to add scopes for the columns you care about, give them meaningful/custom names, and even add scopes that are based on associated (join) records
- =: It defines separate `between` and `between_inclusive` scopes; `active_record_date_range_scopes` provides an `inclusive:` option that can be passed to any scope

### [date_range_scopes](https://github.com/nragaz/date_range_scopes) ([meat](https://github.com/nragaz/date_range_scopes/blob/master/lib/date_range_scopes.rb))
- +: It [supports](https://github.com/nragaz/date_range_scopes/blob/master/lib/date_range_scopes.rb#L28) `date` (`_on`) fields; `active_record_date_range_scopes` currently only supports `datetime` (`_at`) fields (PR welcome!)
- +: It provides `_on`, `_in_week`, `_in_month`, `_in_year` scopes (PR welcome!)
- -: It doesn't provides `_between`/`_after`/`_before` scopes
- -: It uses strings (`"column >="`) for `where` clause; `active_record_date_range_scopes` uses Arel (`arel_table[:column].gteq()`)

### [https://github.com/kevinkaske/readable_date_ranges](https://github.com/kevinkaske/readable_date_ranges) ([meat](https://github.com/kevinkaske/readable_date_ranges/blob/master/lib/readable_date_ranges.rb))
- Its main focus appears to be adding readable range scopes like `created_this_week`, which is nice to have as presets but means it is pretty inflexible (can't specify custom ranges like you can in `active_record_date_range_scopes` and the other similar gems)
- +: It provides `_this_week`, `_this_month`, `_this_year`; `_last_week`, etc. scopes (PR welcome!)

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'active_record_date_range_scopes'
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/active_record_date_range_scopes.
