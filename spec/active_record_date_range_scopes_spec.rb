RSpec.describe ActiveRecord::DateRangeScopes do
  it "has a version number" do
    expect(ActiveRecord::DateRangeScopes.version).to_not be nil
  end

  describe '.created_between and friends' do
    let!(:author1) { Author.create!(name: 'author1') }
    let!(:author2) { Author.create!(name: 'author2') }

    let!(:book_2000)   { Book.create!(created_at: '2000-01-01'.to_time.in_time_zone, author: author1) }
    let!(:book_3y_ago) { Book.create!(created_at: 3.years.ago + 1, author: author1) }
    let!(:book_1w_ago) { Book.create!(created_at: 1.week.ago  + 1, author: author2) }

    it do
      expect(Book.created_between(3.years.ago, 1.year.ago)).to match_array([book_3y_ago])
      expect(Book.created_between(3.years.ago.strftime('%Y-%m-%d'), 1.years.ago.strftime('%Y-%m-%d'))).to \
        match_array(Book.created_between(3.years.ago, 1.year.ago))
      expect(Book.created_after(1.week.ago)).to match_array([book_1w_ago])
      expect(Book.created_before(1.day.ago)).to match_array([book_2000, book_3y_ago, book_1w_ago])
      expect(Book.created_before(book_2000.created_at)).to match_array([book_2000])

      expect(Book.created_on(1.week.ago)).to match_array([book_1w_ago])
      expect(Book.created_on(1.week.ago.to_date)).to match_array([book_1w_ago])
      expect(Book.created_on('2000-01-01'.to_date)    ).to match_array([book_2000])
    end

    it do
      expect(Author.with_any_books_created_between(3.years.ago, 1.year.ago)).to match_array([author1])
      expect(Author.with_any_books_created_before(4.years.ago)).to match_array([author1])
      expect(Author.with_any_books_created_before(400.years.ago)).to match_array([])
      expect(Author.with_any_books_created_after(1.week.ago)).to match_array([author2])
    end
  end
end
