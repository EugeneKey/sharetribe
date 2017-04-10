class CreateMemberEmailBatchJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  # def before(job)
  #   # Set the correct service name to thread for I18n to pick it
  #   ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  # end

  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(job.arguments.first.id)
  end

  def perform(current_community, sender, subject, content, locale)
    current_community.members.find_in_batches(batch_size: 1000) do |member_group|
        member_group.each do |recipient|
          CommunityMemberEmailSentJob.perform_later(
                                      current_community,
                                      sender,
                                      recipient,
                                      subject,
                                      content,
                                      locale)
        end
    end
  end

end
