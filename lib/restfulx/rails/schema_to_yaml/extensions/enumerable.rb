# Enumerable extensions
module Enumerable
  # Helps you find duplicates
  # used in schema_to_yaml.rb for cleanup
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end