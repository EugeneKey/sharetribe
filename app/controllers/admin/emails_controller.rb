# encoding: utf-8
class Admin::EmailsController < Admin::AdminBaseController
  def new
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "email_members"
    @display_knowledge_base_articles = APP_CONFIG.display_knowledge_base_articles
    @knowledge_base_url = APP_CONFIG.knowledge_base_url
  end

  def create
    content = params[:email][:content].gsub(/[”“]/, '"') if params[:email][:content] # Fix UTF-8 quotation marks
    if params[:test_email] == '1'
      CommunityMemberEmailSentJob.perform_later(
                                      @current_user,
                                      @current_user,
                                      @current_community,
                                      "[TEST] "+params[:email][:subject].to_s,
                                      content,
                                      params[:email][:locale])
      render body: t("admin.emails.new.test_sent"), layout: false
    else
      CreateMemberEmailBatchJob.perform_later(
                                @current_user,
                                @current_community,
                                params[:email][:subject],
                                content,
                                params[:email][:locale],
                                params[:email][:recipients])
      flash[:notice] = t("admin.emails.new.email_sent")
      redirect_to :action => :new
    end
  end

  protected

  ADMIN_EMAIL_OPTIONS = [:all_users, :with_listing, :with_listing_no_payment, :with_payment_no_listing, :no_listing_no_payment]

  def admin_email_options
    ADMIN_EMAIL_OPTIONS.map{|option| [I18n.t("admin.emails.new.recipients.options.#{option}"), option] }
  end

  helper_method :admin_email_options
end
