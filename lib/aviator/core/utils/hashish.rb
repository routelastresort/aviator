require 'json'

# Hash-ish!
#
# This class is implemented using composition rather than inheritance so
# that we have control over what operations it exposes to peers.
class Hashish
  include Enumerable

  def initialize(hash={})
    @hash = hash.dup
    stringify_keys
    hashishify_values
  end

  def ==(other_obj)
    other_obj.class == self.class &&
    other_obj.to_hash == self.to_hash
  end

  def [](key)
    @hash[normalize(key)]
  end

  def []=(key, value)
    @hash[normalize(key)] = value
  end

  def dup
    Hashish.new(JSON.parse(@hash.to_json))
  end

  def each(&block)
    @hash.each(&block)
  end

  def empty?
    @hash.empty?
  end

  def has_key?(name)
    @hash.has_key? normalize(name)
  end

  def to_hash
    @hash
  end

  def keys
    @hash.keys
  end

  def length
    @hash.length
  end

  def merge(other_hash)
    Hashish.new(@hash.merge(other_hash))
  end

  def merge!(other_hash)
    @hash.merge! other_hash
    self
  end

  def to_json(obj)
    @hash.to_json(obj)
  end

  def to_s
    str = "{"
    @hash.each do |key, value|
      if value.kind_of? String
        value = "'#{value}'"
      elsif value.nil?
        value = "nil"
      elsif value.kind_of? Array
        value = "[#{value.join(", ")}]"
      end

      str += " #{key}: #{value},"
    end

    str = str[0...-1] + " }"
    str
  end

  private

  # Hashishify all the things!
  def hashishify_values
    @hash.each do |key, value|
      if @hash[key].kind_of? Hash
        @hash[key] = Hashish.new(value)
      elsif @hash[key].kind_of? Array
        @hash[key].each_index do |index|
          element = @hash[key][index]
          if element.kind_of? Hash
            @hash[key][index] = Hashish.new(element)
          end
        end
      end
    end
  end


  def normalize(key)
    if @hash.has_key? key
      key
    elsif key.is_a? Symbol
      key.to_s
    else
      key
    end
  end


  def stringify_keys
    keys = @hash.keys
    keys.each do |key|
      if key.is_a? Symbol
        @hash[key.to_s] = @hash.delete(key)
      end
    end
  end

end
