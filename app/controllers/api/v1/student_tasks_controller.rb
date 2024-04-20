class Api::V1::StudentTasksController < ApplicationController
  before_action :set_participant, only: [:view]
    # GET /student_tasks
    def list
      @student_tasks = StudentTask.from_user current_user
      render json: @student_tasks
    end

    # GET /student_tasks/1
    def show
      render json: @student_task
    end

    # GET /student_tasks/:id/view
  def view
    if @participant
      student_task = StudentTask.create_from_participant(@participant)
      can_submit = @participant.can_submit
      # // TODO hash out encapsulation details
      # can_review_others_work = @participant.can_review_others_work
      # can_view_scores = @participant.can_view_scores
      # // TODO implement displaying of team to view team
      # view_team = some_model.team

      render json: {
        assignment_name: student_task.assignment,
        topic: student_task.topic,
        current_stage: student_task.current_stage,
        stage_deadline: student_task.stage_deadline,
        # permission_granted default false in schema.rb
        permission_granted: student_task.permission_granted,
        can_submit: can_submit,
        # // TODO hash out encapsulation details
        # can_review_others_work: can_review_others_work,
        # can_view_scores: can_view_scores
        # view_team: view_team


      }
    else
      render json: { error: 'Participant not found' }, status: :not_found
    end
  end


    private

    def set_participant
      @participant = Participant.find_by(id: params[:id])
      authorization_check # Ensure this is correctly implemented
    rescue ActiveRecord::RecordNotFound
      @participant = nil
    end

  def authorization_check
    Rails.logger.info "Current user: #{current_user.inspect}" # Log current_user details
    Rails.logger.info "Participant user_id: #{@participant&.user_id}" # Log participant's user_id
    unless current_user && current_user.id == @participant&.user_id
      render json: { error: 'Not Authorized' }, status: :unauthorized
      return false
    end
    true
  end



    # This was used for the can_submit method, however that is now encapsulated in participant

  # def determine_submission_status(participant)
  #   # Assuming 'stage_deadline' from the StudentTask reflects the submission deadline for the current task stage
  #   student_task = StudentTask.create_from_participant(participant)
  #   current_time = Time.current
  #   submission_deadline_passed = student_task.stage_deadline && student_task.stage_deadline < current_time
  #   !submission_deadline_passed
  # end





end