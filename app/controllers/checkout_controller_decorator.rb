Spree::CheckoutController.class_eval do
  skip_before_filter :verify_authenticity_token, :only => [:dps_callback]
  skip_before_filter :load_order, :only => :px_pay_callback

  # Handles the response from PxPay (success or failure) and updates the
  # relevant Payment record.
  def px_pay_callback
    response = Pxpay::Response.new(params).response.to_hash

    payment = Spree::Payment.find(response[:merchant_reference])

    if payment then
      if response[:success] == '1'
        payment.started_processing
        payment.response_code = response[:auth_code]
        payment.save
        payment.complete
        @order = payment.order
        @order.next

        state_callback(:after)
        if @order.state == "complete" || @order.completed?
          state_callback(:before)
          flash.notice = t(:order_processed_successfully)
          flash[:commerce_tracking] = "nothing special"
          redirect_to completion_route
        else
          respond_with(@order, :location => checkout_state_path(@order.state))
        end
      else
        payment.void
        redirect_to cart_path, :notice => 'Your credit card details were declined. Please check your details and try again.'
      end
    else
      # Bad Payment!
      raise Spree::Core::GatewayError, "Unknown merchant_reference: #{response[:merchant_reference]}"
    end
  end

private

  alias :before_payment_without_px_pay_redirection :before_payment
  def before_payment
    before_payment_without_px_pay_redirection
    redirect_to px_pay_gateway.url(@order, request)
  end

  def px_pay_gateway
    @order.available_payment_methods.find { |x| x.is_a?(Spree::Gateway::PxPay) }
  end
end
