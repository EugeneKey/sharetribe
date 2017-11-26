class TransactionConfirmedJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(job.arguments.last.id)
  end

  def perform(transaction, community)
    MailCarrier.deliver_now(PersonMailer.transaction_confirmed(transaction, community))

    if transaction.payment_gateway == "stripe"
      payment = StripeService::Store::StripePayment.get(community.id, transaction.id)
      default_available = APP_CONFIG.stripe_payout_delay.to_f.days.from_now
      available_date = (payment[:available_on] || default_available) + 24.hours
      case StripeService::API::Api.wrapper.charges_mode(community.id)
      when :destination then StripePayoutJob.set(wait_until: available_date).perform_later(transaction, community)
      when :separate then StripePayoutJob.perform_later(transaction, community)
      end
    end
  end
end
