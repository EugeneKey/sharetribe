class TransactionPreauthorizedJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    community_id = Transaction.find(job.arguments.first).community.id
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    MailCarrier.deliver_now(TransactionMailer.transaction_preauthorized(transaction))
  end
end
