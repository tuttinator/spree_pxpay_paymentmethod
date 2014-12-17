Rails.application.routes.draw do
  get '/checkout/pay/callback' => 'spree/checkout#px_pay_callback'
end
