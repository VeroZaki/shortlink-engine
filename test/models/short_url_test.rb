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
end
