require 'tool'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end

  def show

  end

  def new
    @project = Project.new
    @project.projects_tools.build
    @project.projects_tools.build
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    # @project.projects_tools.each { |t|  puts "PT Inspect: " + t.inspect }
    # @project.projects_tools = ProjectsTool.new(project_params[:projects_tools_attributes][0])

    respond_to do |format|
      if @project.save

        project_tools = project_params[:projects_tools_attributes]
        #todo: Fix this disgusting hack!
        project_tools.each { |project_tool| actual = ProjectsTool.new(project_tool[1]); actual.project_id = @project.id; actual.save }


        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
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
      # params[:project][:tools] = selected_tools + "," + new_tools

      # {"0"=>{"id"=>"1"}}

      params.require(:project).permit(:name, :owner, :description, :project_type_id, :projects_tools_attributes => [:project_id, :tool_id])
    end
end
