class RepoTimeline
  class << self

    def load_or_initialize_for(directory_called_from)
      directory = find_in_or_above(directory)
      timeline_directory = "#{directory}/.repo_timeline"

      return 'No repo found.' if directory.nil?

      RepoTimeline.new(directory)
    end

    def find_in_or_above(directory)

      if contains_repo? directory
        directory
      elsif directory.slice!(/\/\w+(\/?)$/)
        get_closest_repository_root(directory)
      else
        nil
      end
    end



    private

    def contains_repo?(directory_path)
      Dir.glob("#{directory_path}/.git").any?
    end
  end
end