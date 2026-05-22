module Admin
  class GroqKeysController < BaseController
    before_action :set_groq_key, only: %i[show update reassign]

    def index
      @groq_keys = GroqKey.includes(:assigned_customer).order(created_at: :desc)
    end

    def show; end

    def new
      @groq_key = GroqKey.new
    end

    def create
      @groq_key = GroqKey.new(groq_key_params.merge(is_assigned: false))

      if @groq_key.save
        redirect_to admin_groq_keys_path, notice: "Groq key added to the pool."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @groq_key.update(groq_key_params)
        redirect_to admin_groq_key_path(@groq_key), notice: "Groq key updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def reassign
      customer = Customer.find(params.require(:customer_id))
      GroqKeyAssigner.new(customer:, preferred_key: @groq_key, force_new_key: true).assign!
      redirect_to admin_customer_path(customer), notice: "Groq key reassigned successfully."
    rescue LicenseError => e
      redirect_to admin_groq_key_path(@groq_key), alert: e.message
    end

    private

    def set_groq_key
      @groq_key = GroqKey.find(params[:id])
    end

    def groq_key_params
      params.require(:groq_key).permit(:api_key)
    end
  end
end
