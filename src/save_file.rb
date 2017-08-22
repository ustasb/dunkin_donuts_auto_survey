require 'json'

class SaveFile
  def initialize(file_name)
    @file_name = "../#{file_name}.json"
  end

  def get(key)
    read[key]
  end

  def set
    File.write(@file_name, yield(read).to_json)
  end

  private

  def read
    File.exists?(@file_name) ? JSON.parse(File.read(@file_name)) : {}
  end
end

