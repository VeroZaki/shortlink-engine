# frozen_string_literal: true

class ShortUrl < ApplicationRecord
  # Base62 alphabet (0-9, A-Z, a-z) for short codes
  BASE62 = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a
  SHORT_CODE_LENGTH = 6
  MAX_COLLISION_RETRIES = 5

  validates :original_url, presence: true
  validates :short_code, presence: true, uniqueness: true
  validate :original_url_must_be_valid

  before_validation :normalize_original_url, on: :create
  before_validation :generate_short_code, on: :create, if: -> { short_code.blank? }

  def self.find_by_short_code!(code)
    find_by!(short_code: code)
  end

  def self.encode_url(original_url)
    normalized = normalize_url(original_url)
    return nil if normalized.blank?

    existing = find_by(original_url: normalized)
    return existing if existing

    create(original_url: normalized)
  end

  def self.decode_to_original(short_url)
    code = extract_short_code(short_url)
    return nil if code.blank?

    record = find_by(short_code: code)
    record&.original_url
  end

  def self.normalize_url(url)
    return nil if url.blank?

    url = url.to_s.strip
    url = "https://#{url}" unless url.match?(%r{\Ahttps?://}i)
    url if url.match?(%r{\Ahttps?://[^\s]+\z}i)
  end

  def self.extract_short_code(short_url)
    return nil if short_url.blank?

    path = short_url.to_s.strip
    path = URI.parse(path).path if path.match?(%r{\Ahttps?://})
    path = path.delete_prefix("/").split("/").first
    path.presence
  end

  private

  def normalize_original_url
    self.original_url = self.class.normalize_url(original_url)
  end

  def original_url_must_be_valid
    return if original_url.blank?

    unless self.class.normalize_url(original_url)
      errors.add(:original_url, "is not a valid URL")
    end
  end

  def generate_short_code
    retries = 0
    loop do
      self.short_code = generate_random_short_code
      break unless ShortUrl.exists?(short_code: short_code)

      retries += 1
      raise "Short code collision after #{MAX_COLLISION_RETRIES} retries" if retries >= MAX_COLLISION_RETRIES
    end
  end

  def generate_random_short_code
    SHORT_CODE_LENGTH.times.map { BASE62.sample }.join
  end
end
