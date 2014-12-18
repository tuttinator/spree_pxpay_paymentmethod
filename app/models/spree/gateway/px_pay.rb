require 'pxpay'

module Spree
  # The PxPay Gateway allows Spree to communicate with the PxPay system,
  # including generating the correct URL to forward the customer to.
  #
  # It differs from most Spree::Gateway implementations in that it does not
  # perform any actions directly via an API (as none exists), but just
  # abstracts access to the pxpay gem.
  class Gateway::PxPay < PaymentMethod

    include Rails.application.routes.url_helpers

    preference :user_id, :string
    preference :key, :string
    preference :currency_input, :string, :default => 'AUD', :description => "3 digit currency code from #{Pxpay::Base.currency_types.join(' ')}"

    attr_accessor :preferred_user_id, :preferred_key, :preferred_currency_input

    def source_required?
      false
    end

    def actions
      %w{}
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      false
    end

    def url(order, request)
      callback = callback_url(request.host, request.protocol, request.port)
      px_pay_request(payment(order), callback).url
    end

private

      # Finds the pending payment or creates a new one.
    def payment(order)

      payment = order.payments.pending.first
      return payment if payment.present?

      payment = order.payments.new
      payment.amount = order.total
      payment.payment_method = self
      payment.save!
      payment
    end

    # Creates a new Pxpay::Request with all the relevant data.
    def px_pay_request(payment, callback_url)
      Pxpay::Base.pxpay_user_id = self.preferred_user_id
      Pxpay::Base.pxpay_key     = self.preferred_key
      Pxpay::Request.new(payment.id, payment.amount, { :url_success => callback_url, :url_failure => callback_url, :currency_input => self.preferred_currency_input })
    end

    # Calculates the url to return to after the PxPay process completes
    def callback_url(host, protocol, port)
      url_for(:controller => 'spree/checkout', :action => 'px_pay_callback', :only_path => false, :host => host, :protocol => protocol, :port => port)
    end
  end
end
