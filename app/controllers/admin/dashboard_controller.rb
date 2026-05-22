module Admin
  class DashboardController < BaseController
    def index
      @total_customers = Customer.count
      @active_customers = Customer.active.count
      @expired_customers = Customer.expired_or_past_due.count
      @suspended_customers = Customer.suspended.count
      @expiring_customers = Customer.expiring_soon.limit(10)
      @groq_total = GroqKey.count
      @groq_assigned = GroqKey.assigned.count
      @recent_activations = ActivationLog.includes(:customer).recent.limit(10)
    end
  end
end
