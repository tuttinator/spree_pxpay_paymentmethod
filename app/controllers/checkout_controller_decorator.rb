CheckoutController.class_eval do
  
  require 'pxpay'
  
  before_filter :redirect_to_dps, :only => [:update]
  skip_before_filter :verify_authenticity_token, :only => [:dps_callback]
  
  def redirect_to_dps
      confirmation_step_present = Gateway.current && Gateway.current.payment_profiles_supported?
      if !confirmation_step_present && params[:state] == "payment"
        return unless params[:order][:payments_attributes]
        load_order
        payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      elsif confirmation_step_present && params[:state] == "confirm"
        load_order
        payment_method = @order.payment_method
      end

      if !payment_method.nil? && payment_method.kind_of?(PaymentMethod::Dppxpay)
        
        request = Pxpay::Request.new(@order.id, @order.total, {:url_success => 'http://killerballs.co.nz/checkout/dps_callback', :url_failure => 'http://killerballs.co.nz/checkout/dps_callback'})        
        
        redirect_to request.url
      end
    end

    def dps_callback
      
      response = Pxpay::Response.new(params).response
        hash = response.to_hash
        
        @reply = hash
        
        logger.warn @reply
      
      
        
      
      
      # @order = Order.find(params[:order_id])
      # 
      #       if @order && params[:status] == 'success'
      #         gateway = PaymentMethod.find(params[:payment_method_id])
      # 
      #         @order.payments.clear
      #         payment = @order.payments.create
      #         payment.started_processing
      #         payment.amount = @order.total
      #         payment.payment_method = gateway
      #         payment.complete
      #         @order.save
      # 
      #         #need to force checkout to complete state
      #         until @order.state == "complete"
      #           if @order.next!
      #             @order.update!
      #             state_callback(:after)
      #           end
      #         end
      # 
      #         flash[:notice] = I18n.t(:order_processed_successfully)
      #         redirect_to completion_route
      #       else
      #         redirect_to checkout_state_path(@order.state)
      #       end
    end
    
  
end