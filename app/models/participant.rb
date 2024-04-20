class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :assignment, foreign_key: 'assignment_id', inverse_of: false

  # This method returns the stage deadline for the participant's current task stage
  def get_stage_deadline
    stage_deadline
  end

  # Wrapper method to check if the participant can review others' work
  def can_review_others_work
    assignment.can_review(self)
  end

  # Check if participant can view the scores of the current assignment
  def can_view_scores
    assignment.scores_viewable?
  end

  # Check if the participant can submit work based on the current stage deadline
  def can_submit
    assignment.submission_allowed(self)
  end

  def fullname
    user.fullname
  end
end
