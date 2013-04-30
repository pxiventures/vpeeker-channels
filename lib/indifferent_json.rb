# Internal: Like JSON, but actually a Hashie::Mash. This allows us to use a
# nice compact structure for serializing (JSON instead of YAML) but also with
# pretty dot syntax.
class IndifferentJson

  def self.load(json)
    # Actually use a Hashie::Mash to provide 'indifferent' access and dot syntax
    return Hashie::Mash.new if json.nil?
    Hashie::Mash.new(JSON.parse(json))
  end

  def self.dump(obj)
    return '{}' if obj.nil?
    obj.to_json
  end
end
