class CommitRecord
  class << self

    def create(project_directory, first_event_string = nil)
      commit = new(project_directory, first_event_string)
      commit.save
    end

    def load(commit_file_path)
      YAML::load(IO.read(commit_file_path).to_s)
    end

  end
end