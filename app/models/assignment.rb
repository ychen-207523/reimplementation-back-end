class Assignment < ApplicationRecord
  include MetricHelper
  has_many :invitations
  has_many :questionnaires

  def review_questionnaire_id
    Questionnaire.find_by_assignment_id id
  end

  def num_review_rounds
    rounds_of_reviews
  end

  def review_phase_active?
    # //TODO workout logic of this function
    # Assuming there's a method or scope to get the due dates ordered by their deadline
    review_phase = stage_deadline.where('deadline_type = ?', 'review').order(:due_at).last
    current_time = Time.current
    review_phase.present? && current_time >= review_phase.due_at && current_time <= review_phase.due_at.end_of_day
  end

  def scores_viewable?
    # //TODO workout logic of this function
    # Here, we'll check the conditions under which scores are viewable
    # For simplicity, let's assume scores are viewable after the review phase
    review_phase_active? && Time.current > stage_deadline.where('deadline_type = ?', 'review').order(:due_at).last.due_at.end_of_day
  end

  # Determine if the next due date from now allows for reviews
  # // TODO hash out assignment_id details
  def can_review(assignment_id = self)
    # Need to ensure that the get_next_due_date method is implemented.
    next_due_date = get_stage_deadline(assignment_id)
    check_condition('review_allowed_id', next_due_date)
  end

  # Use participant's current stage deadline to determine if submission is allowed
  def submission_allowed(participant)
    # Ensure that participant's stage_deadline method is called correctly.
    current_time = Time.current
    stage_deadline = participant.get_stage_deadline
    stage_deadline.present? && stage_deadline > current_time
  end

  private

  def check_condition(condition_column, next_due_date)
    # Assuming next_due_date is an object that has a submission_allowed_id attribute.
    return false if next_due_date.nil?

    right_id = next_due_date.send condition_column
    right = DeadlineRight.find(right_id)
    right && (right.name == 'OK' || right.name == 'Late')
  end
end
