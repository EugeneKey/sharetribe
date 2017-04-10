class ListingCreatedJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(job.arguments.last.id)
  end

  def perform(listing, community)
    # Send reminder about missing payment information
    if MarketplaceService::Listing::Entity.send_payment_settings_reminder?(listing.id, community.id)
      MailCarrier.deliver_now(PersonMailer.payment_settings_reminder(listing, listing.author, community))
    end
  end

end
