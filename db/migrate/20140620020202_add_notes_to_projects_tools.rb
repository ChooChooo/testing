class AddNotesToProjectsTools < ActiveRecord::Migration
  def change
    add_column :projects_tool, :notes, :text
  end
end
