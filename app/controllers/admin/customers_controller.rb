module Admin
  class CustomersController < BaseController
    before_action :set_customer, only: %i[show edit update destroy extend_subscription toggle_status assign_new_key]

    def index
      @customers = Customer.includes(:groq_key)
      @customers = @customers.search(params[:query]) if params[:query].present?
      @customers = @customers.where(status: params[:status]) if params[:status].present?
      @customers = @customers.order(subscription_expiry_date: :asc, created_at: :desc)
    end

    def show
      @activation_logs = @customer.activation_logs.recent
    end

    def new
      @customer = Customer.new(
        subscription_start_date: Date.current,
        subscription_expiry_date: Date.current + 30.days,
        plan_type: "monthly",
        status: "active"
      )
    end

    def create
      @customer = Customer.new(customer_params)
      @customer.license_key = LicenseKeyGenerator.generate

      if @customer.save
        begin
          GroqKeyAssigner.new(customer: @customer).assign! if params[:auto_assign_key] != "0"
          redirect_to admin_customer_path(@customer), notice: "Customer created successfully."
        rescue LicenseError => e
          redirect_to admin_customer_path(@customer), alert: "Customer created, but no Groq key was assigned: #{e.message}"
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "Customer updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @customer.groq_key.present?
        @customer.groq_key.release!
      end

      @customer.destroy!
      redirect_to admin_customers_path, notice: "Customer deleted."
    end

    def extend_subscription
      days = params[:days].to_i
      new_date = [@customer.subscription_expiry_date, Date.current].compact.max + days.days
      @customer.update!(subscription_expiry_date: new_date)
      redirect_to admin_customer_path(@customer), notice: "Subscription extended by #{days} days."
    end

    def toggle_status
      new_status = @customer.active? ? "suspended" : "active"
      @customer.update!(status: new_status)
      redirect_to admin_customer_path(@customer), notice: "Customer status changed to #{new_status}."
    end

    def assign_new_key
      GroqKeyAssigner.new(customer: @customer, force_new_key: true).assign!
      redirect_to admin_customer_path(@customer), notice: "A new Groq key has been assigned."
    rescue LicenseError => e
      redirect_to admin_customer_path(@customer), alert: e.message
    end

    private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(
        :full_name,
        :business_name,
        :email,
        :phone_number,
        :address,
        :device_identifier,
        :plan_type,
        :subscription_start_date,
        :subscription_expiry_date,
        :status,
        :notes
      )
    end
  end
end
