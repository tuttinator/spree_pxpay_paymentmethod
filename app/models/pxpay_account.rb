class PXPayAccount < ActiveRecord::Base
  has_many :payments, :as => :source
  
  def actions
    %w{capture}
  end

  def capture(payment)
    authorization = find_authorization(payment)

    ppx_response = payment.payment_method.provider.capture((100 * payment.amount).to_i, authorization.params["transaction_id"], :currency => payment.payment_method.preferred_currency)
    if ppx_response.success?
      record_log payment, ppx_response
      payment.complete
    else
      gateway_error(ppx_response.message)
    end

  end

  def can_capture?(payment)
    payment.state == "pending"
  end


  # fix for Payment#payment_profiles_supported?
  def payment_gateway
    false
  end

  def record_log(payment, response)
    payment.log_entries.create(:details => response.to_yaml)
  end

  private
  def find_authorization(payment)
    logs = payment.log_entries.all(:order => 'created_at DESC')
    logs.each do |log|
      details = YAML.load(log.details) # return the transaction details
      if (details.params['payment_status'] == 'Pending' && details.params['pending_reason'] == 'authorization')
        return details
      end
    end
    return nil
  end

  def find_capture(payment)
    #find the transaction associated with the original authorization/capture
    logs = payment.log_entries.all(:order => 'created_at DESC')
    logs.each do |log|
      details = YAML.load(log.details) # return the transaction details
      if details.params['payment_status'] == 'Completed'
        return details
      end
    end
    return nil
  end

  def gateway_error(text)
    msg = "#{I18n.t('gateway_error')} ... #{text}"
    logger.error(msg)
    raise Spree::GatewayError.new(msg)
  end
end