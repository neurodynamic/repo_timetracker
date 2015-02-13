def commit_filenames
  Dir.entries("./spec/test_app/.repo_timeline").select { |f| f.include? '__commit__' }
end

def clear_test_app_timeline_folder
  Dir.entries("./spec/test_app/.repo_timeline").select { |f| f.include? '__commit__' }.each do |f|
    File.delete("./spec/test_app/.repo_timeline/#{f}")
  end
end