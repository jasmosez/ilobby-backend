class NotesController < ApplicationController
  before_action :check_current_user
  
  def create
    note = Note.create(note_params)
    render json: note
  end
  
  def update
    note = Note.find(params[:id])
    note.update(note_params)
    render json: note
  end

  private

  def note_params
    params.require(:note).permit(:legislator_id, :user_id, :contents)
  end
end
