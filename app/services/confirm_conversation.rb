class ConfirmConversation
  # How many days before transaction is automatically confirmed should we send a reminder?
  REMIND_DAYS_BEFORE_CLOSING = 2

  def initialize(transaction, user, community)
    @transaction = transaction
    @conversation = transaction.conversation
    @user = user
    @participation = @conversation.participations.find_by_person_id(user.id)
    @offerer = transaction.seller
    @requester = transaction.buyer
    @community = community
  end

  # Listing confirmed by user
  def confirm!
    TransactionConfirmedJob.perform_later(@transaction, @community)
    [3, 10].each do |send_interval|
      TestimonialReminderJob.set(wait_until: send_interval.days.from_now).perform_later(@transaction, nil, @community)
    end
  end

  # Listing canceled by user
  def cancel!
    TransactionCanceledJob.perform_later(@transaction, @community)
  end

  def update_participation(feedback_given)
    @participation.update_attribute(:is_read, true) if @offerer.eql?(@user)

    if @transaction.author == @user
      @transaction.update_attributes(author_skipped_feedback: true) unless feedback_given
    else
      @transaction.update_attributes(starter_skipped_feedback: true) unless feedback_given
    end
  end

  def activate_automatic_confirmation!
    automatic_confirmation_at = @transaction.automatic_confirmation_after_days.days.from_now

    automatic_confirmation_job!(automatic_confirmation_at)
    confirmation_reminder_job!(automatic_confirmation_at)
  end

  def activate_automatic_booking_confirmation_at!(automatic_confirmation_at)
    AutomaticBookingConfirmationJob.set(wait_until: automatic_confirmation_at).perform_later(@transaction, @user, @community)
  end

  private

  def automatic_confirmation_job!(automatic_confirmation_at)
    AutomaticConfirmationJob.set(wait_until: automatic_confirmation_at).perform_later(@transaction, @user, @community)
  end

  def confirmation_reminder_job!(automatic_confirmation_at)
    reminder_email_at           = automatic_confirmation_at - REMIND_DAYS_BEFORE_CLOSING.days
    activate_reminder           = @transaction.automatic_confirmation_after_days > REMIND_DAYS_BEFORE_CLOSING

    if activate_reminder
      ConfirmReminderJob.set(wait_until: reminder_email_at).perform_later(@transaction, @requester, REMIND_DAYS_BEFORE_CLOSING, @community)
    end
  end

end
