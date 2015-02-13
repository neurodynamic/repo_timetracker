class RepoTimeline
  class << self

    def load_or_initialize_for(directory_called_from)
      directory = find_in_or_above(directory_called_from)
      return nil if directory.nil?

      RepoTimeline.new(directory)
    end

    def find_in_or_above(directory)
      return nil if directory.nil?

      if contains_repo? directory
        directory
      elsif directory.slice!(/\/\w+(\/?)$/)
        find_in_or_above(directory)
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