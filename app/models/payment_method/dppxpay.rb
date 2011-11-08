class PaymentMethod::Dppxpay < PaymentMethod
  
  require 'logger'
  
  def actions
    %w{capture void}
  end
  
  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending'].include?(payment.state)
  end
  
  # Indicates whether its possible to void the payment.
  def can_void?(payment)
    payment.state != 'void'
  end
  
  def capture(payment)
    log = Logger.new('log.txt')
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
    log.debug "This is when the capture is made"
    payment.complete
    true
  end
  
  def void(payment)
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
    payment.void
    true
  end
end
