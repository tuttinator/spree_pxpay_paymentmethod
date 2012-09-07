Rails.application.routes.draw do
  match '/checkout/pay/callback' => 'spree/checkout#px_pay_callback'
end
