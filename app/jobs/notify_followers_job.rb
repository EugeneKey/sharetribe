class NotifyFollowersJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(job.arguments.last.id)
  end

  def perform(listing, community)
    return if !listing || listing.closed? || !listing.author
    followers_to_notify(listing.author, community).map do |follower|
      MailCarrier.deliver_now(PersonMailer.new_listing_by_followed_person(listing, follower, community))
    end
  end

  private

  def followers_to_notify(author, community)
    author.followers.members_of(community).select do |follower|
      follower.preferences["email_about_new_listings_by_followed_people"]
    end
  end

  # def listing
  #   @listing ||= Listing.find_by_id(listing_id)
  # end

  # def author
  #   @author ||= listing.author
  # end

  # def community
  #   @community ||= Community.find_by_id(community_id)
  # end

end
