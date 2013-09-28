Spree::CheckoutController.class_eval do
  skip_before_filter :verify_authenticity_token, :only => [:dps_callback]
  skip_before_filter :load_order, :only => :px_pay_callback
  skip_before_filter :ensure_order_not_completed, :only => :px_pay_callback
  skip_before_filter :ensure_checkout_allowed  , :only => :px_pay_callback
  skip_before_filter :ensure_sufficient_stock_lines, :only => :px_pay_callback
  skip_before_filter :ensure_valid_state , :only => :px_pay_callback

  skip_before_filter :associate_user , :only => :px_pay_callback
  skip_before_filter :check_authorization , :only => :px_pay_callback

  # Handles the response from PxPay (success or failure) and updates the
  # relevant Payment record. works with spree 2.0.3
  def px_pay_callback
    response = Pxpay::Response.new(params).response.to_hash

    payment = Spree::Payment.find(response[:merchant_reference])
    if payment

      if response[:success] == '1'
        payment.process!
        payment.response_code = response[:auth_code]
        payment.save
        payment.complete

        order = payment.order
        order.state = 'complete'
        order.completed_at  = Time.now
        order.save

        order.deliver_order_confirmation_email

        flash.notice = Spree.t(:order_processed_successfully)
        redirect_to order_path(order, :token => order.token)
      else
        payment.void
        redirect_to cart_path, :notice => 'Your credit card details were declined. Please check your details and try again.'
      end

    else
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
