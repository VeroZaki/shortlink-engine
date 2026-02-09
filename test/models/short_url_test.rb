# frozen_string_literal: true

require "test_helper"

class ShortUrlTest < ActiveSupport::TestCase
  test "normalizes URL with protocol" do
    assert_equal "https://example.com", ShortUrl.normalize_url("https://example.com")
    assert_equal "http://example.com", ShortUrl.normalize_url("http://example.com")
  end

  test "adds https when no protocol" do
    assert_equal "https://example.com", ShortUrl.normalize_url("example.com")
    assert_equal "https://codesubmit.io/library/react", ShortUrl.normalize_url("codesubmit.io/library/react")
  end

  test "rejects blank or invalid URLs" do
    assert_nil ShortUrl.normalize_url("")
    assert_nil ShortUrl.normalize_url("   ")
    assert_nil ShortUrl.normalize_url("not a url at all")
  end

  test "extract_short_code from full URL" do
    assert_equal "GeAi9K", ShortUrl.extract_short_code("http://your.domain/GeAi9K")
    assert_equal "GeAi9K", ShortUrl.extract_short_code("https://localhost:3000/GeAi9K")
  end

  test "extract_short_code from path only" do
    assert_equal "GeAi9K", ShortUrl.extract_short_code("GeAi9K")
    assert_equal "GeAi9K", ShortUrl.extract_short_code("/GeAi9K")
  end

  test "encode_url creates record and returns it" do
    record = ShortUrl.encode_url("https://example.com/one")
    assert record.persisted?
    assert record.original_url.present?
    assert record.short_code.present?
    assert_equal 6, record.short_code.length
  end

  test "decode_to_original returns URL for existing short code" do
    record = ShortUrl.encode_url("https://example.com/decode-me")
    short_url = "http://localhost/#{record.short_code}"
    assert_equal "https://example.com/decode-me", ShortUrl.decode_to_original(short_url)
  end

  test "decode_to_original returns nil for unknown code" do
    assert_nil ShortUrl.decode_to_original("http://localhost/NoSuch")
  end

  test "encode_url returns nil for invalid URL and does not persist" do
    record = ShortUrl.encode_url("javascript:alert(1)")
    assert_nil record
    assert_equal 0, ShortUrl.where(original_url: "javascript:alert(1)").count
  end

  test "validations prevent invalid URL from being saved" do
    record = ShortUrl.new(original_url: "not a url")
    record.valid?
    assert_includes record.errors[:original_url], "is not a valid URL"
    assert_not record.save
  end

  test "encode_url returns nil when validation fails so controller can respond 422" do
    # e.g. URL that normalizes but fails custom validation
    record = ShortUrl.encode_url("https://")
    assert_nil record
  end

  test "short_code must be base62 and exactly 6 characters" do
    record = ShortUrl.new(original_url: "https://example.com", short_code: "ab-cd")
    record.valid?
    assert_includes record.errors[:short_code], "must contain only letters and numbers (base62)"

    record.short_code = "abc"
    record.valid?
    assert_includes record.errors[:short_code], "must be 6 characters"
  end
end
