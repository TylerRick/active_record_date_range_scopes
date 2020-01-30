# ActiveRecord Date Range Scopes

## Features

- Lets you add scopes that are based on associated (join) records
- If `nil` is passed to any of these scopes, the scope simply has no effect, rather than raising an error. This is useful if you have lots of filters that your users may or may not provide any value for.
- Handles time zones correctly: calls `in_time_zone` on strings/dates that are passed in
- If a date is passed in, it is converted to `beginning_of_day`/`end_of_day` depending on whether it is used in an `_after`/`_before` scope, respectively
- It even lets you mix dates and times in an intuitive way: `Model.created_between(1.week.ago, Date.today)`

## Usage

...


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
