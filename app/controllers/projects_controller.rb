require 'tool'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all.order :name
  end

  def show

  end

  def new   
    @project = Project.new
    @project.projects_tools.build
    @tools = Tool.all.order :name
    @tool_types = ToolType.all.order :name
  end
  
  def github
    
  end
  
  def gh_create
    unless params["gh_user"].blank? || params["gh_repo"].blank?
      @project_name = params["gh_repo"]
      
      client_id = ENV['GITHUB_CLIENT_ID']
      client_secret = ENV['GITHUB_CLIENT_SECRET']
      
      readme = HTTParty.get "https://api.github.com/repos/#{params["gh_user"]}/#{params["gh_repo"]}/readme?client_id=#{client_id}&client_secret=#{client_secret}"
      decoded_readme = Base64.decode64(readme.parsed_response["content"])
      @project_description = decoded_readme.gsub("== README", "")
      
      gemfile = HTTParty.get "https://api.github.com/repos/#{params["gh_user"]}/#{params["gh_repo"]}/contents/Gemfile?client_id=#{client_id}&client_secret=#{client_secret}"
      @decoded_gemfile = Base64.decode64(gemfile.parsed_response["content"])
      
    end
  end

  def edit
    @existing_tools = Array.new
    @project.projects_tools.each do |t|
      @existing_tools << t.tool_id
    end
    @tools = Tool.all.order :name
    @tool_types = ToolType.all.order :name
  end

  def create
    @project = Project.new(:name => params[:project][:name],
        :owner => current_user[:username],
        :description => params[:project][:description],
        :project_type_id => params[:project][:project_type_id])
    @tool_types = ToolType.all.order :name

    respond_to do |format|
      if @project.save

        set_tools

        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_tools
    selected_tools
    new_tools
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        set_tools
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(
          :name,
          :owner,
          :description,
          :project_type_id,
          :projects_tools_attributes => [:project_id, :tool_id, :notes, :_destroy])
    end
    
    def new_tools
      #@tools = Array.new
      puts "??????????????????????"
      puts params
      puts "??????????????????????"
      params.each do |k,v|
        if k.is_a?(String) and k.include?("tool_name_")
          unless v.empty?
            desc_key = "tool_description_" + /\d/.match(k).to_s
            unless save_tool(v, params[desc_key]).nil?
              
              project_tool = ProjectsTool.new(:project_id=>@project.id ,:tool_id=>k)
              project_tool.save
            end
          end
        end
      end 
      #return @tools.join(',')
    end
    
    def selected_tools
      params.each do |k,v|
        if v.is_a?(String) and v == "on"
          ProjectsTool.find_or_create_by(project_id: @project.id, tool_id: k)
        end
      end 
    end
    
    def save_tool(name, description)
      @tool = Tool.find_by name: name
      if @tool.nil?
        new_tools_hash = {"name"=>name, "description"=>description}
  
        @tool = Tool.new(new_tools_hash)
        @tool.save
      end
    end
end
