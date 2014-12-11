class SearchController < ApplicationController

  def search
    unless params['search_params'].blank?
      @search_term = params['search_params']
      results = PgSearch.multisearch(@search_term)

      @results_tools = Hash.new
      @results_projects = Hash.new

      results.each do |result|
        if result.searchable_type == 'Tool'
          @results_tools[result] = Tool.find(result.searchable_id, :select => :name)
        elsif result.searchable_type == 'Project'
          @results_projects[result] = Project.find(result.searchable_id, :select => :name)
        end
      end
    end
  end
end